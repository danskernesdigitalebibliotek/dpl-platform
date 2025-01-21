#!/usr/bin/env bash
# Restore and download files from a Lagoon backup.
set -eo pipefail

LAGOON_ENVIRONMENT="${LAGOON_ENVIRONMENT:-main}"

if [[ -z "${LAGOON_PROJECT}" || -z "${BACKUP_TYPE}" || -z "${BACKUP_DESTINATION}" ]]; then
	echo "usage: LAGOON_PROJECT=<LAGOON_PROJECT> BACKUP_TYPE=<BACKUP_TYPE> BACKUP_DESTINATION=<BACKUP_DESTINATION> $0" >&2
	exit 1
fi

BACKUPS=$(lagoon list backups -p "${LAGOON_PROJECT}" -e "${LAGOON_ENVIRONMENT}" --output-json);
BACKUP_ID=$(echo "$BACKUPS" | jq -r ".data[] | select(.source == \"${BACKUP_TYPE}\") | .backupid" | head -n 1);
BACKUP_URL="Error";
echo -e "\nRetrieving ${BACKUP_TYPE} backup from ${LAGOON_ENVIRONMENT} environment of ${LAGOON_PROJECT} project \n\n";
# Wait a while we wait for the backup to become available.
# It must be retrieved before it can be downloaded.
while [[ $BACKUP_URL == "Error"* ]]; do
  echo -n ".";
  eval "lagoon retrieve backup -p \"${LAGOON_PROJECT}\" -e \"${LAGOON_ENVIRONMENT}\" --backup-id \"${BACKUP_ID}\" --force &> /dev/null" || true;
  # This will return an message in the format "Error: [error message]" if the
  # backup is not available for download yet.
  BACKUP_URL=$(lagoon get backup -p "${LAGOON_PROJECT}" -e "${LAGOON_ENVIRONMENT}" --backup-id "${BACKUP_ID}" 2>/dev/null) || true;
done;
echo -e "\nDownloading backup from ${BACKUP_URL} to ${BACKUP_DESTINATION}\n\n";
curl -o "${BACKUP_DESTINATION}" "${BACKUP_URL}";
