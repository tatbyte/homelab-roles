#!/usr/bin/env bash
# roles/monitoring_status/files/checks/40_backup.sh
# Build the backup-health portion of the managed monitoring status JSON.

set -u -o pipefail

backup_status_path="${MONITORING_STATUS_BACKUP_STATUS_PATH}"
backup_required="${MONITORING_STATUS_BACKUP_REQUIRED}"
backup_warn_after_hours="${MONITORING_STATUS_BACKUP_WARN_AFTER_HOURS}"
backup_fail_after_hours="${MONITORING_STATUS_BACKUP_FAIL_AFTER_HOURS}"
now_epoch="${MONITORING_STATUS_NOW_EPOCH}"

status=ok
backup_status=not_configured
backup_last_success_age_hours=-1
backup_timestamp=""
backup_exit_code=0
backup_source_schema=""
backup_error=""

if [ ! -f "${backup_status_path}" ]; then
  if [ "${backup_required}" = "true" ]; then
    status=warn
    backup_status=missing
    backup_error="backup status file not found"
  fi

  jq -n \
    --arg status "${status}" \
    --arg backup_status "${backup_status}" \
    --arg backup_timestamp "${backup_timestamp}" \
    --arg backup_source_file "${backup_status_path}" \
    --arg backup_source_schema "${backup_source_schema}" \
    --arg backup_error "${backup_error}" \
    --argjson backup_last_success_age_hours "${backup_last_success_age_hours}" \
    --argjson backup_exit_code "${backup_exit_code}" \
    '{
      status: $status,
      details: {
        backup_status: $backup_status,
        backup_last_success_age_hours: $backup_last_success_age_hours,
        backup_source_file: $backup_source_file,
        backup_timestamp: $backup_timestamp,
        backup_source_schema: $backup_source_schema,
        backup_error: $backup_error,
        backup_exit_code: $backup_exit_code
      }
    }'
  exit 0
fi

if ! jq -e 'type == "object"' "${backup_status_path}" >/dev/null 2>&1; then
  status=fail
  backup_status=invalid
  backup_error="backup status file is not valid JSON"
else
  backup_status="$(jq -r '.status // "unknown"' "${backup_status_path}")"
  backup_timestamp="$(jq -r '.timestamp // ""' "${backup_status_path}")"
  backup_exit_code="$(jq -r '.exit_code // 0' "${backup_status_path}")"
  backup_source_schema="$(jq -r '.schema // ""' "${backup_status_path}")"
  backup_error="$(jq -r '.error // ""' "${backup_status_path}")"

  if [ -n "${backup_timestamp}" ]; then
    backup_timestamp_epoch="$(date -d "${backup_timestamp}" +%s 2>/dev/null || printf '')"
    if [ -n "${backup_timestamp_epoch}" ]; then
      backup_last_success_age_hours="$(( (now_epoch - backup_timestamp_epoch) / 3600 ))"
    fi
  fi

  if [ "${backup_status}" = "fail" ] || [ "${backup_exit_code}" -ne 0 ]; then
    status=fail
  elif [ "${backup_status}" = "warn" ]; then
    status=warn
  elif [ "${backup_last_success_age_hours}" -ge "${backup_fail_after_hours}" ] && [ "${backup_last_success_age_hours}" -ge 0 ]; then
    status=fail
  elif [ "${backup_last_success_age_hours}" -ge "${backup_warn_after_hours}" ] && [ "${backup_last_success_age_hours}" -ge 0 ]; then
    status=warn
  fi
fi

jq -n \
  --arg status "${status}" \
  --arg backup_status "${backup_status}" \
  --arg backup_timestamp "${backup_timestamp}" \
  --arg backup_source_file "${backup_status_path}" \
  --arg backup_source_schema "${backup_source_schema}" \
  --arg backup_error "${backup_error}" \
  --argjson backup_last_success_age_hours "${backup_last_success_age_hours}" \
  --argjson backup_exit_code "${backup_exit_code}" \
  '{
    status: $status,
    details: {
      backup_status: $backup_status,
      backup_last_success_age_hours: $backup_last_success_age_hours,
      backup_source_file: $backup_source_file,
      backup_timestamp: $backup_timestamp,
      backup_source_schema: $backup_source_schema,
      backup_error: $backup_error,
      backup_exit_code: $backup_exit_code
    }
  }'
