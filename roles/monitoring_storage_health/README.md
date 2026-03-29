# roles/monitoring_storage_health/README.md

Reference for the `monitoring_storage_health` role.
Explains how this recurring monitoring role inspects one or more declared
storage devices and writes a stable machine-readable storage-health JSON.

## Purpose
- Keep physical or virtual storage-health checks separate from the broader
  `monitoring_status` summary role
- Check declared devices such as root NVMe disks, SATA SSDs, HDDs, SD cards,
  or virtual disks
- Write a stable JSON contract for future collection and alerting

## Managed Files
- `{{ monitoring_storage_health_script_path }}`: rendered storage-health runner
- `/etc/systemd/system/{{ monitoring_storage_health_service_unit }}`: oneshot storage-health service
- `/etc/systemd/system/{{ monitoring_storage_health_timer_unit }}`: recurring schedule
- `{{ monitoring_storage_health_status_path }}`: latest storage-health JSON

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `monitoring_storage_health_enabled` | `true` | no | Whether the role should keep the timer installed and enabled |
| `monitoring_storage_health_status_path` | `/var/lib/monitor/storage-health.json` | no | Output path for the storage-health JSON |
| `monitoring_storage_health_devices` | `[]` | yes when enabled | Declared devices to inspect, each with `device`, optional `label`, optional `type`, and optional `smartctl_device_type` |
| `monitoring_storage_health_sd_error_lookback` | `24 hours` | no | Kernel log lookback window for SD-card style error checks |
| `monitoring_storage_health_timer_on_calendar` | `*-*-* 05:40:00` | no | systemd calendar expression for the timer |

Each device entry supports:

```yaml
- label: root_disk
  device: /dev/sda
  type: smart
  smartctl_device_type: sat
```

Supported types:
- `auto`
- `smart`
- `nvme`
- `sd`
- `none`

Optional SMART transport hint:
- `smartctl_device_type`
  Use this when `smartctl` needs an explicit `-d` transport such as `sat`
  for USB-attached SATA SSDs or HDDs.

## Usage

```yaml
- name: Apply recurring storage health monitoring
  hosts: monitoring
  become: true
  roles:
    - role: monitoring_storage_health
```

Example inventory vars:

```yaml
# group_vars/monitoring/monitoring_storage_health.yml
monitoring_storage_health_status_dir: /var/lib/monitor
monitoring_storage_health_status_path: "{{ monitoring_storage_health_status_dir }}/storage-health.json"

# host_vars/lab/vars.yml
monitoring_storage_health_devices:
  - label: root_disk
    device: /dev/sda
    type: smart
```

## Notes
- This role focuses on declared device health only; filesystem usage still
  belongs in `monitoring_status`.
- Use `type: none` for virtual disks or devices where health probing should be
  skipped while still keeping the device visible in the JSON contract.
- `auto` maps `nvme*` devices to `nvme`, `mmcblk*` devices to `sd`, and other
  device paths to `smart`.

## Dependencies
None

## License
MIT
