#!/usr/bin/env bash
# roles/monitoring_status/files/checks/10_system.sh
# Build the system-health portion of the managed monitoring status JSON.

set -u -o pipefail

memory_warn_pct="${MONITORING_STATUS_SYSTEM_MEMORY_WARN_PCT}"
memory_fail_pct="${MONITORING_STATUS_SYSTEM_MEMORY_FAIL_PCT}"
load_warn_per_cpu="${MONITORING_STATUS_SYSTEM_LOAD_WARN_PER_CPU}"
load_fail_per_cpu="${MONITORING_STATUS_SYSTEM_LOAD_FAIL_PER_CPU}"

read -r load_1m load_5m load_15m _ < /proc/loadavg
cpu_count="$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || printf '1')"
uptime_seconds="$(awk '{print int($1)}' /proc/uptime)"
mem_total_kb="$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)"
mem_available_kb="$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)"

if [ -z "${mem_available_kb}" ]; then
  mem_available_kb="$(awk '/^MemFree:/ {print $2}' /proc/meminfo)"
fi

memory_used_pct="$(
  awk -v total="${mem_total_kb}" -v available="${mem_available_kb}" '
    BEGIN {
      if (total <= 0) {
        print 0
      } else {
        printf "%.0f", ((total - available) / total) * 100
      }
    }
  '
)"
load_per_cpu_1m="$(
  awk -v load_value="${load_1m}" -v cpu="${cpu_count}" '
    BEGIN {
      if (cpu <= 0) {
        print 0
      } else {
        printf "%.2f", load_value / cpu
      }
    }
  '
)"

status=ok
if awk "BEGIN {exit !(${load_per_cpu_1m} >= ${load_fail_per_cpu})}"; then
  status=fail
elif [ "${memory_used_pct}" -ge "${memory_fail_pct}" ]; then
  status=fail
elif awk "BEGIN {exit !(${load_per_cpu_1m} >= ${load_warn_per_cpu})}"; then
  status=warn
elif [ "${memory_used_pct}" -ge "${memory_warn_pct}" ]; then
  status=warn
fi

jq -n \
  --arg status "${status}" \
  --argjson system_uptime_seconds "${uptime_seconds}" \
  --argjson system_cpu_count "${cpu_count}" \
  --argjson system_load_1m "${load_1m}" \
  --argjson system_load_5m "${load_5m}" \
  --argjson system_load_15m "${load_15m}" \
  --argjson system_load_per_cpu_1m "${load_per_cpu_1m}" \
  --argjson memory_used_pct "${memory_used_pct}" \
  '{
    status: $status,
    details: {
      system_uptime_seconds: $system_uptime_seconds,
      system_cpu_count: $system_cpu_count,
      system_load_1m: $system_load_1m,
      system_load_5m: $system_load_5m,
      system_load_15m: $system_load_15m,
      system_load_per_cpu_1m: $system_load_per_cpu_1m,
      memory_used_pct: $memory_used_pct
    }
  }'
