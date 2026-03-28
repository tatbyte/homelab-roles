# roles/monitoring_status/README.md

Reference for the `monitoring_status` role.
Explains how this recurring monitoring role runs host-local checks through a
systemd timer and writes a stable unified status JSON for each host.

## Purpose
- Build `/var/lib/monitor/status.json` on every monitored host
- Keep monitoring as a consumer of backup JSON instead of re-running Restic
- Expose a stable machine-readable contract for future collection and alerting

## Managed Files
- `{{ monitoring_status_script_path }}`: rendered status runner
- `{{ monitoring_status_checks_path }}/`: copied shell check scripts
- `/etc/systemd/system/{{ monitoring_status_service_unit }}`: oneshot status service
- `/etc/systemd/system/{{ monitoring_status_timer_unit }}`: recurring schedule
- `{{ monitoring_status_status_path }}`: latest unified host status JSON

## Checks
- `system`: CPU-count, load, memory use, and uptime summary
- `storage`: root filesystem usage, optional additional mount usage, plus optional SMART, NVMe, and SD-card hints
- `docker`: daemon, container, and health-state summary
- `backup`: read-only validation of `backup_restic` JSON output
- `network`: optional ping-based reachability checks

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `monitoring_status_enabled` | `true` | no | Whether the role should keep the timer installed and enabled |
| `monitoring_status_status_path` | `/var/lib/monitor/status.json` | no | Output path for the unified host status JSON |
| `monitoring_status_backup_status_path` | `backup_restic_status_path` fallback | no | Backup JSON path consumed by the backup check |
| `monitoring_status_backup_required` | `backup_include_restic` fallback | no | Treat a missing backup JSON file as a warning when true |
| `monitoring_status_storage_additional_mounts` | `[]` | no | Optional extra mount points whose usage should be checked alongside `/` |
| `monitoring_status_storage_missing_additional_mount_status` | `warn` | no | Severity for missing optional extra mounts: `warn`, `ignore`, or `fail` |
| `monitoring_status_storage_device` | `""` | no | Optional explicit block device to inspect for storage health |
| `monitoring_status_storage_type` | `auto` | no | Storage check mode: `auto`, `smart`, `nvme`, `sd`, or `none` |
| `monitoring_status_docker_mode` | `auto` | no | Docker check mode: `auto`, `required`, or `ignore` |
| `monitoring_status_network_targets` | `[]` | no | Optional ping targets used by the network check |
| `monitoring_status_timer_on_calendar` | `*-*-* *:05:00` | no | systemd calendar expression for the timer |

## Usage

```yaml
- name: Apply recurring monitoring status
  hosts: monitoring
  become: true
  roles:
    - role: monitoring_status
```

Example inventory vars:

```yaml
# group_vars/monitoring/monitoring_status.yml
monitoring_status_status_dir: /var/lib/monitor
monitoring_status_status_path: "{{ monitoring_status_status_dir }}/status.json"
monitoring_status_backup_status_path: "{{ backup_restic_status_path }}"
monitoring_status_backup_required: "{{ backup_include_restic | default(false) }}"
monitoring_status_storage_additional_mounts: []
monitoring_status_storage_missing_additional_mount_status: warn
monitoring_status_storage_device: ""
monitoring_status_storage_type: auto
monitoring_status_network_targets: []
```

## Notes
- The role always reads backup state from JSON and never runs Restic itself.
- The timer writes `monitor_status_v1`, while each check keeps its own logic
  small and shell-based under `files/checks/`.
- Hosts without Docker can leave the default `auto` mode, which treats Docker
  as informational unless the daemon or CLI is present.
- Leave `monitoring_status_storage_device` empty when the root-backed
  auto-detect path is good enough, or set it per host when the important
  storage device sits behind LVM, maps to a different underlying disk, or
  should skip device-health probing entirely with `monitoring_status_storage_type: none`.
- Use `monitoring_status_storage_additional_mounts` when important data lives on
  non-root mounts such as `/mnt/storage` or `/mnt/downloads`; those usage checks
  share the same warn/fail thresholds as `/`.
- Missing optional extra mounts default to `warn`, not `fail`, so hosts can
  predeclare expected data paths without breaking the whole storage check
  before those mounts exist. Set
  `monitoring_status_storage_missing_additional_mount_status: fail` when a
  specific mount must always be present.

## Dependencies
None

## License
MIT
