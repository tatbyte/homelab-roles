#!/usr/bin/env bash
# roles/monitoring_status/files/checks/50_network.sh
# Build the optional network-reachability portion of the managed monitoring
# status JSON.

set -u -o pipefail

network_targets_json="${MONITORING_STATUS_NETWORK_TARGETS_JSON}"
network_ping_count="${MONITORING_STATUS_NETWORK_PING_COUNT}"
network_ping_timeout_seconds="${MONITORING_STATUS_NETWORK_PING_TIMEOUT_SECONDS}"

mapfile -t network_targets < <(printf '%s\n' "${network_targets_json}" | jq -r '.[]')

if [ "${#network_targets[@]}" -eq 0 ]; then
  jq -n \
    --arg status ok \
    --argjson network_target_count 0 \
    --argjson network_reachable_count 0 \
    --argjson network_unreachable_count 0 \
    --argjson network_unreachable_targets '[]' \
    '{
      status: $status,
      details: {
        network_target_count: $network_target_count,
        network_reachable_count: $network_reachable_count,
        network_unreachable_count: $network_unreachable_count,
        network_unreachable_targets: $network_unreachable_targets
      }
    }'
  exit 0
fi

status=ok
network_reachable_count=0
unreachable_targets=()

if ! command -v ping >/dev/null 2>&1; then
  jq -n \
    --arg status fail \
    --argjson network_target_count "${#network_targets[@]}" \
    --argjson network_reachable_count 0 \
    --argjson network_unreachable_count "${#network_targets[@]}" \
    --arg error "ping command not found" \
    --argjson network_unreachable_targets "$(printf '%s\n' "${network_targets[@]}" | jq -R -s 'split("\n") | map(select(length > 0))')" \
    '{
      status: $status,
      details: {
        network_target_count: $network_target_count,
        network_reachable_count: $network_reachable_count,
        network_unreachable_count: $network_unreachable_count,
        network_unreachable_targets: $network_unreachable_targets,
        network_error: $error
      }
    }'
  exit 0
fi

for target in "${network_targets[@]}"; do
  if ping -c "${network_ping_count}" -W "${network_ping_timeout_seconds}" "${target}" >/dev/null 2>&1; then
    network_reachable_count="$((network_reachable_count + 1))"
  else
    unreachable_targets+=("${target}")
  fi
done

network_target_count="${#network_targets[@]}"
network_unreachable_count="${#unreachable_targets[@]}"
network_unreachable_targets_json="$(
  printf '%s\n' "${unreachable_targets[@]}" \
    | jq -R -s 'split("\n") | map(select(length > 0))'
)"

if [ "${network_unreachable_count}" -eq "${network_target_count}" ]; then
  status=fail
elif [ "${network_unreachable_count}" -gt 0 ]; then
  status=warn
fi

jq -n \
  --arg status "${status}" \
  --argjson network_target_count "${network_target_count}" \
  --argjson network_reachable_count "${network_reachable_count}" \
  --argjson network_unreachable_count "${network_unreachable_count}" \
  --argjson network_unreachable_targets "${network_unreachable_targets_json}" \
  '{
    status: $status,
    details: {
      network_target_count: $network_target_count,
      network_reachable_count: $network_reachable_count,
      network_unreachable_count: $network_unreachable_count,
      network_unreachable_targets: $network_unreachable_targets
    }
  }'
