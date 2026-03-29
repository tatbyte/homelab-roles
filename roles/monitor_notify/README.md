# roles/monitor_notify/README.md

Reference for the `monitor_notify` role.
Explains how the role reads the aggregated collector index and sends
deduplicated ntfy alerts for a small set of actionable monitoring states.

## Purpose
- Read the aggregated collector index from `monitor_collect`
- Send ntfy alerts when Docker containers are down or a backup failed
- Suppress duplicate notifications until the alert set changes

## Managed Files
- `{{ monitor_notify_script_path }}`: rendered notification runner
- `/etc/systemd/system/{{ monitor_notify_service_unit }}`: oneshot notification service
- `/etc/systemd/system/{{ monitor_notify_timer_unit }}`: recurring schedule
- `{{ monitor_notify_state_hash_path }}`: last-sent alert fingerprint used for deduplication
- `{{ monitor_notify_status_path }}`: latest notification-run JSON status

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `monitor_notify_enabled` | `true` | no | Whether the notification role should be active on the host |
| `monitor_notify_index_path` | collector index path | yes when enabled | Aggregated `monitor_collect` index consumed by the notification runner |
| `monitor_notify_ntfy_url` | `""` | yes when enabled | Full ntfy topic URL that receives notifications |
| `monitor_notify_include_docker_down` | `true` | no | Whether to alert when a host reports non-running Docker containers |
| `monitor_notify_include_backup_failed` | `true` | no | Whether to alert when a host reports `backup.status == "error"` |
| `monitor_notify_timer_on_calendar` | `*-*-* *:50:00` | no | systemd calendar expression for the recurring notification timer |

## Notes
- The role currently keeps notifications intentionally small and opinionated:
  one ntfy endpoint, one deduplicated alert set, and two alert classes.
- The role writes `{{ monitor_notify_status_path }}` so future dashboards or
  collectors can reason about notification health without parsing logs.
- When all alerts clear, the role removes the saved dedupe hash so the next
  real problem is sent again immediately.

## Dependencies
None

## License
MIT
