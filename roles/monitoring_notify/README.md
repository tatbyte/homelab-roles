# roles/monitoring_notify/README.md

Reference for the `monitoring_notify` role.
Explains how the role reads the aggregated collector index and sends
deduplicated ntfy alerts for a small set of actionable monitoring states.

## Purpose
- Read the aggregated collector index from `monitoring_collect`
- Send ntfy alerts when Docker containers are down or a backup failed
- Send ntfy alerts when the collector cannot refresh one or more host contracts
- Reuse one fleet-state ntfy message format for both real warnings and `_now`
  validation sends
- Support review-only Docker-tag notes in `_now` notifications without letting
  Docker-tag checks drive the warning state
- Suppress duplicate notifications until the alert set changes

## Managed Files
- `{{ monitoring_notify_script_path }}`: rendered notification runner
- `/etc/systemd/system/{{ monitoring_notify_service_unit }}`: oneshot notification service
- `/etc/systemd/system/{{ monitoring_notify_timer_unit }}`: recurring schedule
- `{{ monitoring_notify_state_hash_path }}`: last-sent alert fingerprint used for deduplication
- `{{ monitoring_notify_status_path }}`: latest notification-run JSON status

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `monitoring_notify_enabled` | `true` | no | Whether the notification role should be active on the host |
| `monitoring_notify_manage_existing_install` | `false` | no | Reuse the currently installed ntfy URL when the inventory omits it locally |
| `monitoring_notify_index_path` | collector index path | yes when enabled | Aggregated `monitoring_collect` index consumed by the notification runner |
| `monitoring_notify_ntfy_url` | `""` | yes when enabled | Full ntfy topic URL that receives notifications |
| `monitoring_notify_include_docker_down` | `true` | no | Whether to alert when a host reports non-running Docker containers |
| `monitoring_notify_include_backup_failed` | `true` | no | Whether to alert when a host reports `backup.status == "error"` |
| `monitoring_notify_include_collect_errors` | `true` | no | Whether to alert when the collector index reports host contract fetch errors or stale cached monitoring data |
| `monitoring_notify_timer_on_calendar` | `*-*-* *:50:00` | no | systemd calendar expression for the recurring notification timer |

## Notes
- The role currently keeps notifications intentionally small and opinionated:
  one ntfy endpoint, one deduplicated alert set, and a small set of alert classes.
- Docker-tag updates stay out of the normal recurring alert set, and the
  collector summary now treats them as review-only data rather than host-level
  warnings.
- The direct `_now` path can still include Docker-tag review notes, but the
  notification body stays in the same fleet-state format used by real warning
  sends.
- When `monitoring_notify_manage_existing_install` is true and the current
  script already exists on the host, the role can recover the live ntfy URL
  from that script before it validates and re-renders the service.
- The role writes `{{ monitoring_notify_status_path }}` so future dashboards or
  collectors can reason about notification health without parsing logs.
- When all alerts clear, the role removes the saved dedupe hash so the next
  real problem is sent again immediately.

## Dependencies
None

## License
MIT
