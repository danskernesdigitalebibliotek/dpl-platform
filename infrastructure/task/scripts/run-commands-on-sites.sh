#!/usr/bin/env bash
# Run a file of shell commands against the sites in sites.yaml, a few sites in
# parallel, with retries and a log file per site. See --help.

set -uo pipefail

if [[ -t 1 && "${TERM:-}" != "dumb" ]]; then
  C_GREEN=$'\033[32m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[33m'
  C_CYAN=$'\033[36m';  C_DIM=$'\033[2m';  C_BOLD=$'\033[1m'
  C_RESET=$'\033[0m'
else
  C_GREEN=""; C_RED=""; C_YELLOW=""; C_CYAN=""
  C_DIM="";   C_BOLD="";  C_RESET=""
fi

# Drop blank lines and comments. An inline `#` only starts a comment after
# whitespace, so a `#` inside a quoted command survives.
read_lines() {
  awk '
    {
      sub(/[[:space:]]+#.*$/, "")
      sub(/^[[:space:]]+/, "")
      sub(/[[:space:]]+$/, "")
    }
    /^#/ { next }
    NF
  ' "$1"
}

run_command() {
  local cmd="$1" log="$2"
  local attempt rc=1
  for ((attempt=1; attempt<=RETRIES; attempt++)); do
    printf '\n$ (attempt %d/%d) %s\n' "$attempt" "$RETRIES" "$cmd" >> "$log"
    # Without </dev/null a command that reads stdin swallows the rest of the
    # commands file.
    bash -c "$cmd" < /dev/null >> "$log" 2>&1
    rc=$?
    (( rc == 0 )) && return 0
    if (( attempt < RETRIES )); then
      printf '[exit %d, retrying in %ss]\n' "$rc" "$RETRY_DELAY" >> "$log"
      sleep "$RETRY_DELAY"
    fi
  done
  printf '[gave up after %d attempts, exit %d]\n' "$RETRIES" "$rc" >> "$log"
  return 1
}

# Runs the commands for one site in order and stops at the first failure.
run_site() {
  local site="$1"
  local log="$LOG_DIR/${site}.log"
  local started cmd rendered
  started=$(date +%s)
  {
    printf '# site: %s\n' "$site"
    printf '# started: %s\n' "$(date -Iseconds)"
  } > "$log"

  while IFS= read -r cmd; do
    rendered="${cmd//\{site\}/$site}"
    if ! run_command "$rendered" "$log"; then
      printf 'fail\t%s\t%d\n' "$rendered" $(( $(date +%s) - started )) > "$STATE_DIR/results/$site"
      return 1
    fi
  done < "$STATE_DIR/commands"

  printf 'ok\t\t%d\n' $(( $(date +%s) - started )) > "$STATE_DIR/results/$site"
}

# Atomic counter for the [n/total] prefix: mkdir fails if another worker got
# there first.
next_index() {
  local i=1
  while ! mkdir "$STATE_DIR/seq/$i" 2>/dev/null; do
    i=$((i + 1))
  done
  printf '%d' "$i"
}

worker() {
  local site="$1" ok=0 idx elapsed
  run_site "$site" && ok=1
  idx=$(next_index)
  elapsed=$(awk -F'\t' '{print $3}' "$STATE_DIR/results/$site")
  if (( ok )); then
    printf '%s[%d/%d]%s %s✓%s %s %s(%ss)%s\n' \
      "$C_DIM" "$idx" "$SITE_COUNT" "$C_RESET" "$C_GREEN" "$C_RESET" "$site" \
      "$C_DIM" "$elapsed" "$C_RESET"
  else
    printf '%s[%d/%d]%s %s✗%s %s %s(%ss — see %s/%s.log)%s\n' \
      "$C_DIM" "$idx" "$SITE_COUNT" "$C_RESET" "$C_RED" "$C_RESET" "$site" \
      "$C_DIM" "$elapsed" "$LOG_DIR" "$site" "$C_RESET"
  fi
}

# xargs calls the script again in worker mode instead of an exported function,
# because macOS strips exported bash functions from /usr/bin/xargs' environment.
if [[ "${1:-}" == "--worker" ]]; then
  worker "$2"
  exit
fi

COMMANDS_FILE=""
SITES_FILE=""
PLAN=""
PARALLEL=3
RETRIES=5
RETRY_DELAY=1
LOG_DIR=""
DRY_RUN=0

usage() {
  cat <<EOF
Usage: $0 -c FILE [options]

Runs each line of FILE as a shell command for every site in sites.yaml
(\$SITES_CONFIG). {site} in a command is replaced with the site's key.

  -c, --commands FILE     Commands to run per site, one per line (required)
      --plan PLAN         Only sites with this plan, e.g. webmaster for the
                          sites that have a moduletest environment
  -s, --sites FILE        Use the sites in FILE, one per line, instead of
                          sites.yaml, e.g. failed.txt from an earlier run
  -j, --parallel N        Sites to run in parallel (default: 3)
  -r, --retries N         Attempts per command (default: 5)
  -d, --retry-delay SEC   Seconds between attempts (default: 1)
      --log-dir DIR       Where to write the per-site logs
                          (default: run-commands-logs/<timestamp>)
      --dry-run           Show the sites and the commands for one of them
  -h, --help              Show this help

Blank lines and # comments are ignored in FILE.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--commands)    COMMANDS_FILE="$2"; shift 2 ;;
    --plan)           PLAN="$2"; shift 2 ;;
    -s|--sites)       SITES_FILE="$2"; shift 2 ;;
    -j|--parallel)    PARALLEL="$2"; shift 2 ;;
    -r|--retries)     RETRIES="$2"; shift 2 ;;
    -d|--retry-delay) RETRY_DELAY="$2"; shift 2 ;;
    --log-dir)        LOG_DIR="$2"; shift 2 ;;
    --dry-run)        DRY_RUN=1; shift ;;
    -h|--help)        usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

die() { echo "${C_RED}error: $1${C_RESET}" >&2; exit 2; }

[[ -n "$COMMANDS_FILE" ]] || { usage >&2; exit 2; }
[[ -f "$COMMANDS_FILE" ]] || die "file not found: $COMMANDS_FILE"
COMMANDS=$(read_lines "$COMMANDS_FILE")
[[ -n "$COMMANDS" ]] || die "$COMMANDS_FILE has no commands"

if [[ -n "$SITES_FILE" ]]; then
  [[ -z "$PLAN" ]] || die "--plan cannot be combined with --sites"
  [[ -f "$SITES_FILE" ]] || die "file not found: $SITES_FILE"
  SITES=$(read_lines "$SITES_FILE")
else
  [[ -n "${SITES_CONFIG:-}" ]] || die "SITES_CONFIG is not set"
  [[ -f "$SITES_CONFIG" ]] || die "file not found: $SITES_CONFIG"
  SITES=$(PLAN="$PLAN" yq '... comments="" | .sites | to_entries | .[]
    | select(strenv(PLAN) == "" or .value.plan == strenv(PLAN)) | .key' "$SITES_CONFIG")
fi
[[ -n "$SITES" ]] || die "no sites selected"

SITE_COUNT=$(printf '%s\n' "$SITES" | wc -l | tr -d ' ')
COMMAND_COUNT=$(printf '%s\n' "$COMMANDS" | wc -l | tr -d ' ')

if (( DRY_RUN )); then
  printf '%sDRY RUN — %d sites × %d commands (parallel=%d)%s\n\n' \
    "$C_BOLD" "$SITE_COUNT" "$COMMAND_COUNT" "$PARALLEL" "$C_RESET"
  printf '%s\n' "$SITES" | paste -sd ' ' -
  first=$(printf '%s\n' "$SITES" | head -n 1)
  printf '\n%s  [%s]%s\n' "$C_CYAN" "$first" "$C_RESET"
  while IFS= read -r cmd; do
    printf '    $ %s\n' "${cmd//\{site\}/$first}"
  done <<< "$COMMANDS"
  exit 0
fi

LOG_DIR="${LOG_DIR:-run-commands-logs/$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$LOG_DIR"

STATE_DIR=$(mktemp -d)
mkdir -p "$STATE_DIR/seq" "$STATE_DIR/results"
printf '%s\n' "$COMMANDS" > "$STATE_DIR/commands"
trap 'rm -rf "$STATE_DIR"' EXIT

printf '%s▶ %d sites × %d commands  %s(parallel=%d, retries=%d)%s\n' \
  "$C_BOLD" "$SITE_COUNT" "$COMMAND_COUNT" "$C_DIM" "$PARALLEL" "$RETRIES" "$C_RESET"
printf '%s  logs: %s/%s\n\n' "$C_DIM" "$LOG_DIR" "$C_RESET"

export SITE_COUNT RETRIES RETRY_DELAY LOG_DIR STATE_DIR
export C_GREEN C_RED C_YELLOW C_CYAN C_DIM C_BOLD C_RESET

START_TIME=$(date +%s)

# Lagoon does not cope well with many concurrent ssh sessions, hence the low
# default parallelism.
printf '%s\n' "$SITES" | tr '\n' '\0' | \
  xargs -0 -n 1 -P "$PARALLEL" -I {} bash "$0" --worker {}

TOTAL_ELAPSED=$(( $(date +%s) - START_TIME ))

OK_COUNT=0
FAILED_SITES=()
while IFS= read -r site; do
  [[ -f "$STATE_DIR/results/$site" ]] || continue
  if [[ "$(awk -F'\t' '{print $1}' "$STATE_DIR/results/$site")" == "ok" ]]; then
    OK_COUNT=$((OK_COUNT + 1))
  else
    FAILED_SITES+=("$site")
  fi
done <<< "$SITES"
FAIL_COUNT=${#FAILED_SITES[@]}

printf '\n%s%s%s\n' "$C_DIM" "────────────────────────────────────────────────────────────" "$C_RESET"
printf '%sdone%s  %s✓ %d ok%s  %s✗ %d failed%s  in %ss\n' \
  "$C_BOLD" "$C_RESET" "$C_GREEN" "$OK_COUNT" "$C_RESET" \
  "$C_RED" "$FAIL_COUNT" "$C_RESET" "$TOTAL_ELAPSED"

if (( FAIL_COUNT > 0 )); then
  printf '\n%sfailed sites:%s\n' "$C_RED" "$C_RESET"
  for site in "${FAILED_SITES[@]}"; do
    printf '  ✗ %s\n' "$site"
    printf '%s      cmd: %s%s\n' "$C_DIM" "$(awk -F'\t' '{print $2}' "$STATE_DIR/results/$site")" "$C_RESET"
    printf '%s      log: %s/%s.log%s\n' "$C_DIM" "$LOG_DIR" "$site" "$C_RESET"
  done
  printf '%s\n' "${FAILED_SITES[@]}" > "$LOG_DIR/failed.txt"
  printf '\n%sre-run only the failed sites with:%s\n' "$C_YELLOW" "$C_RESET"
  printf '  --sites %s/failed.txt -c %s\n' "$LOG_DIR" "$COMMANDS_FILE"
fi

printf '\n%sper-site logs are in %s/%s\n' "$C_DIM" "$LOG_DIR" "$C_RESET"

(( FAIL_COUNT == 0 )) || exit 1
