#!/usr/bin/env zx
//
// Manual backup of a Lagoon environment, for when k8up backups are unavailable.
// Goes entirely through the Lagoon API - no cluster access needed.
//
// Per environment: two independent tasks, database then files, so a files
// failure cannot lose a good dump. Each task uploads its own artifact via
// uploadFilesForTask using the TASK_DATA_ID/TASK_SSH_HOST/TASK_API_HOST vars
// Lagoon injects into task pods; both land on the task in the UI.
//
// Files delta is measured from the last successful `nginx` backup, never from a
// previous manual run, so every artifact is self-contained: restore is one k8up
// snapshot plus one delta, never a chain.
//
// Artifacts persist indefinitely (~tens of MB/run). Pruning deliberately absent:
// taking a backup must never delete one. Prune via deleteFilesForTask.
//
//   --project        repeatable, comma-separated. Exclusive with --all.
//   --all            every site in sites.yaml
//   --environment    default main
//   --since          "YYYY-MM-DD HH:MM:SS"; needed when no nginx backup exists
//   --max-delta-mb   default 2048; see cap in filesBody
//   --concurrency    default 3; sites share MariaDB instances
//   --timeout        minutes per task, default 30
//
// Requires zx and a configured lagoon CLI.

$.verbose = false

// lagoon CLI reads a task script from stdin, so it blocks for EOF while stdin
// is open. zx defaults to stdio 'pipe' -> every lagoon call hangs. Detach it.
$.stdio = ["ignore", "pipe", "pipe"]

// Not a typo: sites.yaml is platform-wide and never moved off dplplat01.
// dplplat02/ has no copy. Sibling scripts do the same.
const sitesYamlPath = path.resolve(import.meta.dirname, "../../environments/dplplat01/sites.yaml")

const environment = String(argv.environment ?? "main")
const since = argv.since ? String(argv.since) : null
const maxDeltaMb = Number(argv["max-delta-mb"] ?? 2048)
const concurrency = Number(argv.concurrency ?? 3)
const timeoutMs = Number(argv.timeout ?? 30) * 60 * 1000

if (!argv.all && !argv.project) {
  console.error("usage: --project <name>[,<name>...] (repeatable) | --all")
  console.error("       [--environment main] [--since 'YYYY-MM-DD HH:MM:SS']")
  console.error("       [--max-delta-mb 2048] [--concurrency 3] [--timeout 30]")
  process.exit(1)
}
if (argv.all && argv.project) {
  console.error("--project and --all are mutually exclusive")
  process.exit(1)
}
// Spliced into shell source in filesBody, unlike everything else which goes
// through zx quoting. Pin the shape here so the template gets a known literal.
if (since && !/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/.test(since)) {
  console.error(`--since must be "YYYY-MM-DD HH:MM:SS", got: ${since}`)
  process.exit(1)
}

// --- project selection ------------------------------------------------------

// --project is repeatable and accepts comma-separated lists:
//   --project a --project b   /   --project a,b
function explicitProjects() {
  return []
    .concat(argv.project)
    .flatMap((p) => String(p).split(","))
    .map((p) => p.trim())
    .filter(Boolean)
}

function sitesFromYaml() {
  if (!fs.existsSync(sitesYamlPath)) {
    console.error(`sites.yaml not found at ${sitesYamlPath}`)
    process.exit(1)
  }
  return Object.keys(YAML.parse(fs.readFileSync(sitesYamlPath, "utf-8")).sites ?? {})
}

const projects = argv.all ? sitesFromYaml() : explicitProjects()
if (argv.all) echo(`Loaded ${projects.length} sites from ${path.relative(process.cwd(), sitesYamlPath)}`)

// --- lagoon helpers ---------------------------------------------------------

async function lagoonRaw(query) {
  const out = await $`lagoon raw --skip-update-check --raw ${query} --output-json`
  return JSON.parse(out.stdout)
}

// One query answers both "does this env exist" and "when was its last nginx
// backup", for every project. Per-project lookups would be a CLI spawn each,
// in front of the db->files chain. limit:20: backups alternate nginx/mariadb,
// so ~10 nginx snapshots of headroom if nginx has been failing.
async function platformIndex() {
  const data = await lagoonRaw(
    `{ allProjects { name environments { name backups(limit:20) { source created } } } }`
  )
  const index = new Map()
  for (const p of data.allProjects ?? []) {
    const envs = new Map()
    for (const e of p.environments ?? []) {
      const nginx = (e.backups ?? [])
        .filter((b) => b.source === "nginx" && b.created)
        .map((b) => b.created)
        .sort()
      envs.set(e.name, nginx.at(-1) ?? null)
    }
    index.set(p.name, envs)
  }
  return index
}

async function submitTask(project, name, body) {
  const tmp = path.join(os.tmpdir(), `lagoon-backup-site-${project}-${environment}-${Date.now()}.sh`)
  fs.writeFileSync(tmp, body)
  try {
    const out =
      await $`lagoon run custom --skip-update-check --force -p ${project} -e ${environment} -S cli -N ${name} -s ${tmp} --output-json`
    const id = JSON.parse(out.stdout)?.data?.id
    if (!id) throw new Error(`could not read task id from: ${out.stdout}`)
    return id
  } finally {
    fs.rmSync(tmp, { force: true })
  }
}

// Completing without an artifact is a failure - that silent shape is why this
// script exists. 3s matches observed durations (~11s db, ~23s files); longer
// intervals spend most of a task asleep after it already finished.
async function awaitTaskArtifact(id) {
  const deadline = Date.now() + timeoutMs
  while (Date.now() < deadline) {
    const task = (await lagoonRaw(`{ taskById(id:${id}) { status files { filename } } }`)).taskById
    if (["complete", "failed", "cancelled"].includes(task.status)) {
      if (task.status !== "complete") throw new Error(`task ${id} ${task.status}`)
      if (!task.files?.length) throw new Error(`task ${id} completed but attached no artifact`)
      return artifactSize(id)
    }
    await sleep(3000)
  }
  throw new Error(`task ${id} did not finish within ${timeoutMs / 60000} minutes`)
}

// The API exposes no file size, so read it from the `ls -lh` both bodies run.
// Fetched once on completion rather than on every poll - logs are the heaviest
// field on the task. Size is cosmetic, so a parse miss is not an error.
async function artifactSize(id) {
  try {
    const { logs } = (await lagoonRaw(`{ taskById(id:${id}) { logs } }`)).taskById
    const line = (logs || "").split("\n").find((l) => /^-[rwx-]{9}/.test(l) && l.includes("/tmp/"))
    const size = line?.trim().split(/\s+/)[4]
    return size ? `${size}B` : null
  } catch {
    return null
  }
}

// --- remote task bodies -----------------------------------------------------
//
// Run inside the task pod. Only ${...} interpolates, so $LAGOON_PROJECT and
// $TASK_DATA_ID survive verbatim; shell ${VAR:-default} must be escaped \${...}.
// Keep this note with the bodies if they move.

const uploadStanza = `
TOKEN="$(ssh -p \${LAGOON_CONFIG_TOKEN_PORT:-$TASK_SSH_PORT} -t lagoon@\${LAGOON_CONFIG_TOKEN_HOST:-$TASK_SSH_HOST} token)"
curl --fail-with-body -sS "\${LAGOON_CONFIG_API_HOST:-$TASK_API_HOST}"/graphql \\
  -H "Authorization: Bearer $TOKEN" \\
  -F operations='{ "query": "mutation ($task: Int!, $files: [Upload!]!) { uploadFilesForTask(input:{task:$task, files:$files}) { id files { filename } } }", "variables": { "task": '"$TASK_DATA_ID"', "files": [null] } }' \\
  -F map='{ "0": ["variables.files.0"] }' \\
  -F 0=@"$artifact"
`

const databaseBody = `set -e
file="/tmp/$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH-$(date --iso-8601=seconds).sql"

# All DBs are in-cluster mariadb-operator, which offers no TLS. Revisit
# --skip-ssl if TLS is ever enabled there.
drush sql-dump --extra-dump="--no-tablespaces --skip-ssl" --result-file=$file --gzip

artifact="$file.gz"
ls -lh "$artifact"
${uploadStanza}
rm -f "$artifact"
`

const filesBody = (cutoff) => `set -e
CUTOFF="${cutoff}"
MAX_DELTA_MB="${maxDeltaMb}"
# dpl-cms image layout, not site-specific. Same path in restore-site.mjs.
FILESDIR="/app/cms/web/sites/default/files"

artifact="/tmp/$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH-$(date --iso-8601=seconds)-files-delta.tar.gz"
cd "$FILESDIR"

# One definition so count, size and tar cannot drift. styles/ excluded: Drupal
# regenerates derivatives on demand.
delta_find() { find . -type f -newermt "$CUTOFF" -not -path './styles/*' "$@"; }

count=$(delta_find -printf '.' | wc -c)
bytes=$(delta_find -printf '%s\\n' | awk '{s+=$1} END {print s+0}')
mb=$((bytes / 1024 / 1024))

echo "delta cutoff : $CUTOFF"
echo "files matched: $count"
echo "delta size   : $mb MB"

# 2048m cap: gitops/dplplat02/ingress-nginx/values.yaml proxy-body-size, which
# the API ingress inherits, plus Lagoon's client_max_body_size. Fail before the
# tar, not during the upload.
if [ "$mb" -gt "$MAX_DELTA_MB" ]; then
  echo "ERROR: delta is $mb MB, above the $MAX_DELTA_MB MB limit for task-file upload." >&2
  echo "       Stream it instead: lagoon ssh -p <project> -e <env> -s cli -C 'tar -cz ...'" >&2
  exit 1
fi

delta_find -print0 > /tmp/delta-list
tar -czf "$artifact" --null -T /tmp/delta-list
ls -lh "$artifact"
${uploadStanza}
rm -f "$artifact" /tmp/delta-list
`

// --- selection --------------------------------------------------------------

const platform = await platformIndex()

const selected = []
const skipped = []
const state = new Map()
for (const project of projects) {
  const envs = platform.get(project)
  if (!envs) {
    skipped.push({ project, reason: "project not found in Lagoon" })
  } else if (!envs.has(environment)) {
    skipped.push({ project, reason: `no '${environment}' environment` })
  } else {
    selected.push(project)
    state.set(project, { db: "pending", files: "pending", sizes: {}, errors: {}, error: null })
  }
}

// --- progress rendering -----------------------------------------------------
//
// Stages are pending -> running -> ok|failed; done/failed are derived, not
// stored. The table redraws in place by moving the cursor up exactly as many
// lines as were last written, so it needs the whole table on screen - disabled
// for --all (100+ rows) and non-TTY, which fall back to one line per project
// plus a final table. rows is sampled once; a resize degrades cosmetically.

const HEAD = "PROJECT / ENVIRONMENT"
const rowLabel = (project) => `${project} / ${environment}`
const NAME_W = Math.max(
  HEAD.length + 2,
  ...selected.map((p) => rowLabel(p).length + 2),
  ...skipped.map((s) => rowLabel(s.project).length + 2)
)
// "n/a": stage never ran (project failed first). Terminal, but not a failure.
const TERMINAL = ["ok", "failed", "n/a"]
const isDone = (s) => TERMINAL.includes(s.db) && TERMINAL.includes(s.files)
const isFailed = (s) => Boolean(s.error) || s.db === "failed" || s.files === "failed"

let renderedLines = 0

function statusCell(value, size, width = 0) {
  const label = { pending: "pending", running: "running", ok: "ok", failed: "FAILED", "n/a": "-" }[value]
  const text = value === "ok" && size ? `ok (${size})` : label
  // pending stays uncoloured - inherits the terminal default, readable on both
  // light and dark. Greys are near-invisible on dark.
  const paint = { running: chalk.yellow, ok: chalk.green, failed: chalk.red }[value] ?? ((s) => s)
  return paint(text.padEnd(width))
}

function tableLines() {
  const values = [...state.values()]
  const doneCount = values.filter(isDone).length
  const failedCount = values.filter(isFailed).length
  const lines = [
    chalk.bold(`${HEAD.padEnd(NAME_W)}${"DATABASE".padEnd(14)}FILES`),
    "-".repeat(NAME_W + 26),
  ]
  for (const [project, s] of state) {
    lines.push(`${rowLabel(project).padEnd(NAME_W)}${statusCell(s.db, s.sizes.db, 14)}${statusCell(s.files, s.sizes.files)}`)
  }
  for (const s of skipped) {
    lines.push(`${rowLabel(s.project).padEnd(NAME_W)}${chalk.yellow(`skipped - ${s.reason}`)}`)
  }
  lines.push("-".repeat(NAME_W + 26))
  // ok counts finished work only; showing a running project as ok would lie.
  lines.push(
    `[${doneCount}/${state.size}]  ` +
      `${chalk.green(`${doneCount - failedCount} ok`)}, ` +
      `${failedCount ? chalk.red(`${failedCount} failed`) : "0 failed"}, ` +
      `${skipped.length} skipped`
  )
  return lines
}

// Measured, not predicted: a new row in tableLines() cannot break the fit check.
const liveTable = Boolean(process.stdout.isTTY) && tableLines().length + 3 < (process.stdout.rows || 24)

// Up by exactly the previous line count; clear each line so shorter text leaves
// no remnants; one write per frame to avoid tearing.
function render() {
  const lines = tableLines()
  const up = renderedLines ? `\x1b[${renderedLines}A` : ""
  process.stdout.write(up + lines.map((l) => `\x1b[2K${l}`).join("\n") + "\n")
  renderedLines = lines.length
}

// Single progress sink: redraw, or one line per finished project.
function onChange(project) {
  if (liveTable) return render()
  const s = state.get(project)
  if (isDone(s)) echo(`${isFailed(s) ? chalk.red("✗") : chalk.green("✓")} ${rowLabel(project)}`)
}

// --- per-environment work ---------------------------------------------------

async function backupProject(project) {
  const s = state.get(project)
  const cutoff = since ?? platform.get(project).get(environment)

  if (!cutoff) {
    // Neither stage ran - project-level failure, not a stage failure.
    s.error = "no successful nginx backup to delta from; pass --since to override"
    s.db = s.files = "n/a"
    onChange(project)
    return
  }

  // Database first and independently: a files failure still leaves a good dump.
  const stages = [
    ["db", "Manual backup: database", databaseBody],
    ["files", `Manual backup: files delta since ${cutoff}`, filesBody(cutoff)],
  ]
  for (const [key, name, body] of stages) {
    s[key] = "running"
    onChange(project)
    try {
      s.sizes[key] = await awaitTaskArtifact(await submitTask(project, name, body))
      s[key] = "ok"
    } catch (e) {
      s[key] = "failed"
      s.errors[key] = e.message
    }
  }
  onChange(project)
}

async function runPool(items, limit, worker) {
  let next = 0
  await Promise.all(
    Array.from({ length: Math.min(limit, items.length) }, async () => {
      for (let i = next++; i < items.length; i = next++) await worker(items[i])
    })
  )
}

// --- main -------------------------------------------------------------------

echo(`Backing up '${environment}' for ${selected.length} project(s), concurrency ${concurrency}\n`)
if (liveTable) render()

await runPool(selected, concurrency, backupProject)

// Live mode already left the final state on screen.
if (!liveTable) {
  echo("")
  for (const line of tableLines()) echo(line)
}

// --- failures ---------------------------------------------------------------

const failed = [...state.entries()].filter(([, s]) => isFailed(s))

if (failed.length) {
  echo("")
  echo(chalk.bold.red("FAILURES"))
  echo("-".repeat(NAME_W + 26))
  for (const [project, s] of failed) {
    echo(chalk.bold(rowLabel(project)))
    if (s.error) echo(`  ${chalk.red(s.error)}`)
    for (const [stage, message] of Object.entries(s.errors)) {
      echo(`  ${chalk.red(`${stage === "db" ? "database" : stage}: ${message}`)}`)
    }
  }
  process.exit(1)
}
