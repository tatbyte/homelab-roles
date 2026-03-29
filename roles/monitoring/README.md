# roles/monitoring/README.md

Reference for the `monitoring` role.
Explains how the aggregate monitoring layer includes optional focused roles
such as `monitoring_authorized_key`, `monitoring_status`, and
`monitoring_storage_health`, plus the collector companion `monitor_collect`.

## Purpose
- Keep monitoring-related execution order explicit in one aggregate role
- Let consumer inventories opt into SSH transport setup and host status
  generation independently
- Keep dedicated device-health checks separate from the lighter host-status
  summary when inventories want both
- Allow one designated host to aggregate monitoring JSON contracts and
  optionally publish a static dashboard through Traefik
- Leave room for future monitoring companions without changing playbook names

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `monitoring_include_authorized_key` | `false` | no | Include `monitoring_authorized_key` in the aggregate layer |
| `monitoring_include_status` | `false` | no | Include `monitoring_status` in the aggregate layer |
| `monitoring_include_storage_health` | `false` | no | Include `monitoring_storage_health` in the aggregate layer |
| `monitoring_include_collect` | `false` | no | Include `monitor_collect` in the aggregate layer |

## Usage

```yaml
- name: Apply monitoring layer
  hosts: monitoring
  become: true
  roles:
    - role: monitoring
```

Use inventory precedence to keep the layer disabled by default, enable it for a
whole monitoring group, and still allow a host to opt out or add more toggles:

```yaml
# group_vars/all/monitoring.yml
monitoring_include_authorized_key: false
monitoring_include_status: false
monitoring_include_storage_health: false
monitoring_include_collect: false

# group_vars/monitoring/monitoring.yml
monitoring_include_authorized_key: true
monitoring_include_status: true
monitoring_include_storage_health: true

# host_vars/lab/vars.yml
monitoring_include_authorized_key: false
monitoring_include_status: false
monitoring_include_storage_health: false
monitoring_include_collect: true
```

When `monitor_collect` needs recurring SSH access to remote hosts, keep the
remote public-key setup in `monitoring_authorized_key` and keep any optional
collector private key in `monitor_collect` itself. That keeps SSH transport
inside the monitoring layer instead of leaking it into `base`. The collector
dashboard can then stay behind the existing Traefik + ACME path while the
collector itself continues to pull the raw `status.json`,
`storage-health.json`, and `restic-backup.json` contracts from the monitored
hosts.

## Dependencies
None

## License
MIT
