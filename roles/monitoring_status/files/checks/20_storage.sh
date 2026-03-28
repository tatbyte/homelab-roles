#!/usr/bin/env bash
# roles/monitoring_status/files/checks/20_storage.sh
# Build the storage-health portion of the managed monitoring status JSON.

set -u -o pipefail

root_mount="${MONITORING_STATUS_STORAGE_ROOT_MOUNT}"
additional_mounts_json="${MONITORING_STATUS_STORAGE_ADDITIONAL_MOUNTS_JSON}"
missing_additional_mount_status="${MONITORING_STATUS_STORAGE_MISSING_ADDITIONAL_MOUNT_STATUS}"
warn_pct="${MONITORING_STATUS_STORAGE_WARN_PCT}"
fail_pct="${MONITORING_STATUS_STORAGE_FAIL_PCT}"
sd_error_lookback="${MONITORING_STATUS_STORAGE_SD_ERROR_LOOKBACK}"
configured_storage_device="${MONITORING_STATUS_STORAGE_DEVICE}"
configured_storage_type="${MONITORING_STATUS_STORAGE_TYPE}"

trim_block_device() {
  local source_device="$1"

  case "${source_device}" in
    /dev/nvme*n*p[0-9]*)
      printf '%s\n' "${source_device%p[0-9]*}"
      ;;
    /dev/mmcblk*p[0-9]*)
      printf '%s\n' "${source_device%p[0-9]*}"
      ;;
    /dev/[hsv]d[a-z][0-9]*)
      printf '%s\n' "${source_device%[0-9]*}"
      ;;
    *)
      printf '%s\n' "${source_device}"
      ;;
  esac
}

root_source="$(findmnt -n -o SOURCE "${root_mount}" 2>/dev/null || printf '')"
root_device="$(trim_block_device "${root_source}")"
storage_device="${root_device}"
storage_type="${configured_storage_type}"
root_used_pct="$(df -P "${root_mount}" 2>/dev/null | awk 'NR == 2 {gsub(/%/, "", $5); print $5}')"
status=ok
storage_smart_health=unknown
storage_nvme_critical_warning=0
storage_sd_error_count=0
storage_mounts_json='[]'
storage_mount_max_used_pct=0
storage_missing_mounts_json='[]'

append_mount_json() {
  local mount_path="$1"
  local mount_source="$2"
  local mount_used_pct="$3"

  storage_mounts_json="$(
    jq -n \
      --argjson current "${storage_mounts_json}" \
      --arg mount_path "${mount_path}" \
      --arg mount_source "${mount_source}" \
      --argjson mount_used_pct "${mount_used_pct}" \
      '$current + [{
        mount: $mount_path,
        source: $mount_source,
        used_pct: $mount_used_pct
      }]'
  )"
}

append_missing_mount_json() {
  local mount_path="$1"

  storage_missing_mounts_json="$(
    jq -n \
      --argjson current "${storage_missing_mounts_json}" \
      --arg mount_path "${mount_path}" \
      '$current + [$mount_path]'
  )"
}

evaluate_mount_usage() {
  local mount_path="$1"
  local required_mount="$2"
  local mount_source
  local mount_used_pct

  mount_source="$(findmnt -n -o SOURCE "${mount_path}" 2>/dev/null || printf '')"
  mount_used_pct="$(df -P "${mount_path}" 2>/dev/null | awk 'NR == 2 {gsub(/%/, "", $5); print $5}')"

  if [ -z "${mount_used_pct}" ]; then
    append_missing_mount_json "${mount_path}"
    append_mount_json "${mount_path}" "${mount_source}" 'null'
    if [ "${required_mount}" = "true" ]; then
      status=fail
    elif [ "${missing_additional_mount_status}" = "fail" ]; then
      status=fail
    elif [ "${missing_additional_mount_status}" = "warn" ] && [ "${status}" = "ok" ]; then
      status=warn
    fi
    return
  fi

  append_mount_json "${mount_path}" "${mount_source}" "${mount_used_pct}"

  if [ "${mount_used_pct}" -gt "${storage_mount_max_used_pct}" ]; then
    storage_mount_max_used_pct="${mount_used_pct}"
  fi

  if [ "${mount_used_pct}" -ge "${fail_pct}" ]; then
    status=fail
  elif [ "${mount_used_pct}" -ge "${warn_pct}" ] && [ "${status}" = "ok" ]; then
    status=warn
  fi
}

if [ -n "${configured_storage_device}" ]; then
  storage_device="${configured_storage_device}"
fi

if [ "${storage_type}" = "auto" ]; then
  case "${storage_device}" in
    /dev/nvme*)
      storage_type=nvme
      ;;
    /dev/mmcblk*)
      storage_type=sd
      ;;
    '')
      storage_type=none
      ;;
    *)
      storage_type=smart
      ;;
  esac
fi

evaluate_mount_usage "${root_mount}" "true"
root_used_pct="$(jq -r --arg root_mount "${root_mount}" '.[] | select(.mount == $root_mount) | .used_pct' <<<"${storage_mounts_json}")"
if [ "${root_used_pct}" = "null" ] || [ -z "${root_used_pct}" ]; then
  root_used_pct=0
fi

while IFS= read -r additional_mount; do
  if [ -n "${additional_mount}" ] && [ "${additional_mount}" != "${root_mount}" ]; then
    evaluate_mount_usage "${additional_mount}" "false"
  fi
done < <(jq -r '.[]' <<<"${additional_mounts_json}")

if [ "${storage_type}" = "smart" ] && [ -n "${storage_device}" ] && [ -b "${storage_device}" ] && command -v smartctl >/dev/null 2>&1; then
  smart_output="$(smartctl -H "${storage_device}" 2>&1 || true)"
  if printf '%s\n' "${smart_output}" | grep -Eq 'SMART overall-health self-assessment test result: PASSED|SMART Health Status: OK'; then
    storage_smart_health=ok
  elif printf '%s\n' "${smart_output}" | grep -Eq 'SMART overall-health self-assessment test result: FAILED|SMART Health Status: FAILED'; then
    storage_smart_health=fail
    status=fail
  fi
fi

if [ "${storage_type}" = "nvme" ] && [ -n "${storage_device}" ] && [ -b "${storage_device}" ] && command -v nvme >/dev/null 2>&1; then
  storage_nvme_critical_warning="$(nvme smart-log "${storage_device}" 2>/dev/null | awk '/critical_warning/ {print $3; exit}')"
  if [ -z "${storage_nvme_critical_warning}" ]; then
    storage_nvme_critical_warning=0
  fi
  if [ "${storage_nvme_critical_warning}" != "0" ]; then
    status=fail
  fi
fi

if [ "${storage_type}" = "sd" ] && [ -n "${storage_device}" ] && command -v journalctl >/dev/null 2>&1; then
  storage_sd_error_count="$(
    journalctl -k --since "${sd_error_lookback}" --no-pager 2>/dev/null \
      | grep -Eic 'mmc[0-9]+:|Buffer I/O error|EXT4-fs error|I/O error|card never left busy state' \
      || true
  )"
  if [ "${storage_sd_error_count}" -gt 0 ] && [ "${status}" = "ok" ]; then
    status=warn
  fi
fi

jq -n \
  --arg status "${status}" \
  --arg storage_root_mount "${root_mount}" \
  --arg storage_root_source "${root_source}" \
  --arg storage_root_device "${storage_device}" \
  --arg storage_root_device_detected "${root_device}" \
  --arg storage_type "${storage_type}" \
  --arg storage_smart_health "${storage_smart_health}" \
  --argjson storage_mounts "${storage_mounts_json}" \
  --argjson storage_missing_mounts "${storage_missing_mounts_json}" \
  --argjson storage_mount_max_used_pct "${storage_mount_max_used_pct}" \
  --argjson root_used_pct "${root_used_pct}" \
  --argjson storage_nvme_critical_warning "${storage_nvme_critical_warning}" \
  --argjson storage_sd_error_count "${storage_sd_error_count}" \
  '{
    status: $status,
    details: {
      storage_root_mount: $storage_root_mount,
      storage_root_source: $storage_root_source,
      storage_root_device: $storage_root_device,
      storage_root_device_detected: $storage_root_device_detected,
      storage_type: $storage_type,
      storage_mounts: $storage_mounts,
      storage_missing_mounts: $storage_missing_mounts,
      storage_mount_max_used_pct: $storage_mount_max_used_pct,
      root_used_pct: $root_used_pct,
      storage_smart_health: $storage_smart_health,
      storage_nvme_critical_warning: $storage_nvme_critical_warning,
      storage_sd_error_count: $storage_sd_error_count
    }
  }'
