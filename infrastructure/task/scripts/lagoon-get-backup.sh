#!/usr/bin/env bash
# Restore and download files from a Lagoon backup.
set -eo pipefail

LAGOON_ENVIRONMENT="${LAGOON_ENVIRONMENT:-main}"
# The entry in the list of backups for the provided type to retrieve for the
# given backup type. 1 is the most recent.
BACKUP_ENTRY_INDEX=$((${BACKUP_ENTRY:-1}-1));

if [[ -z "${LAGOON_PROJECT}" || -z "${BACKUP_TYPE}" || -z "${BACKUP_DESTINATION}" ]]; then
	echo "usage: LAGOON_PROJECT=<LAGOON_PROJECT> BACKUP_TYPE=<BACKUP_TYPE> BACKUP_DESTINATION=<BACKUP_DESTINATION> $0" >&2
	exit 1
fi

BACKUPS=$(lagoon list backups -p "${LAGOON_PROJECT}" -e "${LAGOON_ENVIRONMENT}" --output-json);
BACKUP_ID=$(echo "$BACKUPS" | jq -r ".data | map(select(.source == \"${BACKUP_TYPE}\")) | nth(${BACKUP_ENTRY_INDEX}) | .backupid");
BACKUP_RESULT="Error";
echo -e "\nRetrieving ${BACKUP_ENTRY}. ${BACKUP_TYPE} backup with id ${BACKUP_ID} from ${LAGOON_ENVIRONMENT} environment of ${LAGOON_PROJECT} project \n\n";
# Wait a while we wait for the backup to become available.
# It must be retrieved before it can be downloaded.
while [[ $BACKUP_RESULT == "Error"* ]]; do
  echo -n ".";
  eval "lagoon retrieve backup -p \"${LAGOON_PROJECT}\" -e \"${LAGOON_ENVIRONMENT}\" --backup-id \"${BACKUP_ID}\" --force &> /dev/null" || true;
  # This will return an message in the format "Error: [error message]" if the
  # backup is not available for download yet.
  BACKUP_RESULT=$(lagoon get backup -p "${LAGOON_PROJECT}" -e "${LAGOON_ENVIRONMENT}" --backup-id "${BACKUP_ID}" --output-json 2>&1) || true;
done;
BACKUP_URL=$(echo "$BACKUP_RESULT" | jq -r ".result")
echo -e "\nDownloading backup from ${BACKUP_URL} to ${BACKUP_DESTINATION}\n\n";
curl -o "${BACKUP_DESTINATION}" "${BACKUP_URL}";
