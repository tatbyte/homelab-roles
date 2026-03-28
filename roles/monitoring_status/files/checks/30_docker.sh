#!/usr/bin/env bash
# roles/monitoring_status/files/checks/30_docker.sh
# Build the Docker-health portion of the managed monitoring status JSON.

set -u -o pipefail

docker_mode="${MONITORING_STATUS_DOCKER_MODE}"
docker_service_name="${MONITORING_STATUS_DOCKER_SERVICE_NAME}"
docker_service_unit="${docker_service_name}"
if [ "${docker_service_unit%.service}" = "${docker_service_unit}" ]; then
  docker_service_unit="${docker_service_unit}.service"
fi

docker_service=not-installed
docker_unit_file_state=not-found
docker_cli_present=false
containers_total=0
containers_running=0
containers_unhealthy=0
containers_exited=0
docker_unhealthy_containers_json='[]'
docker_non_running_containers_json='[]'
status=ok

if [ "${docker_mode}" = "ignore" ]; then
  jq -n \
    --arg status ok \
    --arg docker_service ignored \
    --arg docker_unit_file_state ignored \
    --argjson docker_cli_present false \
    --argjson containers_total 0 \
    --argjson containers_running 0 \
    --argjson containers_unhealthy 0 \
    --argjson containers_exited 0 \
    --argjson docker_unhealthy_containers '[]' \
    --argjson docker_non_running_containers '[]' \
    '{
      status: $status,
      details: {
        docker_service: $docker_service,
        docker_unit_file_state: $docker_unit_file_state,
        docker_cli_present: $docker_cli_present,
        containers_total: $containers_total,
        containers_running: $containers_running,
        containers_unhealthy: $containers_unhealthy,
        containers_exited: $containers_exited,
        docker_unhealthy_containers: $docker_unhealthy_containers,
        docker_non_running_containers: $docker_non_running_containers
      }
    }'
  exit 0
fi

if command -v docker >/dev/null 2>&1; then
  docker_cli_present=true
fi

docker_service_show="$(systemctl show "${docker_service_unit}" --property=LoadState --property=ActiveState --property=UnitFileState 2>/dev/null || true)"
docker_load_state="$(printf '%s\n' "${docker_service_show}" | awk -F= '/^LoadState=/ {print $2; exit}')"
docker_active_state="$(printf '%s\n' "${docker_service_show}" | awk -F= '/^ActiveState=/ {print $2; exit}')"
docker_unit_file_state="$(printf '%s\n' "${docker_service_show}" | awk -F= '/^UnitFileState=/ {print $2; exit}')"

if [ "${docker_load_state}" != "not-found" ] && [ -n "${docker_active_state}" ]; then
  docker_service="${docker_active_state}"
fi

if [ "${docker_mode}" = "required" ] && [ "${docker_service}" = "not-installed" ] && [ "${docker_cli_present}" != "true" ]; then
  status=fail
fi

if [ "${docker_service}" != "not-installed" ] && [ "${docker_service}" != "active" ]; then
  status=fail
fi

if [ "${docker_service}" = "active" ] && [ "${docker_cli_present}" = "true" ]; then
  docker_ps_output="$(docker ps -a --format '{{.Names}}|{{.State}}|{{.Status}}' 2>/dev/null || true)"
  if [ -n "${docker_ps_output}" ]; then
    containers_total="$(printf '%s\n' "${docker_ps_output}" | sed '/^$/d' | wc -l)"
    containers_running="$(printf '%s\n' "${docker_ps_output}" | awk -F'|' '$2 == "running" {count++} END {print count + 0}')"
    containers_unhealthy="$(printf '%s\n' "${docker_ps_output}" | grep -Ec 'unhealthy' || true)"
    containers_exited="$(printf '%s\n' "${docker_ps_output}" | awk -F'|' '$2 != "running" {count++} END {print count + 0}')"
    docker_unhealthy_containers_json="$(
      printf '%s\n' "${docker_ps_output}" \
        | awk -F'|' '$3 ~ /unhealthy/ {print $1}' \
        | jq -R -s 'split("\n") | map(select(length > 0))'
    )"
    docker_non_running_containers_json="$(
      printf '%s\n' "${docker_ps_output}" \
        | awk -F'|' '$2 != "running" {print $1}' \
        | jq -R -s 'split("\n") | map(select(length > 0))'
    )"
  fi
fi

if [ "${docker_service}" = "active" ] && [ "${docker_cli_present}" != "true" ] && [ "${status}" = "ok" ]; then
  status=warn
fi

if [ "${containers_unhealthy}" -gt 0 ] && [ "${status}" = "ok" ]; then
  status=warn
fi

if [ "${containers_exited}" -gt 0 ] && [ "${status}" = "ok" ]; then
  status=warn
fi

jq -n \
  --arg status "${status}" \
  --arg docker_service "${docker_service}" \
  --arg docker_unit_file_state "${docker_unit_file_state}" \
  --argjson docker_cli_present "${docker_cli_present}" \
  --argjson containers_total "${containers_total}" \
  --argjson containers_running "${containers_running}" \
  --argjson containers_unhealthy "${containers_unhealthy}" \
  --argjson containers_exited "${containers_exited}" \
  --argjson docker_unhealthy_containers "${docker_unhealthy_containers_json}" \
  --argjson docker_non_running_containers "${docker_non_running_containers_json}" \
  '{
    status: $status,
    details: {
      docker_service: $docker_service,
      docker_unit_file_state: $docker_unit_file_state,
      docker_cli_present: $docker_cli_present,
      containers_total: $containers_total,
      containers_running: $containers_running,
      containers_unhealthy: $containers_unhealthy,
      containers_exited: $containers_exited,
      docker_unhealthy_containers: $docker_unhealthy_containers,
      docker_non_running_containers: $docker_non_running_containers
    }
  }'
