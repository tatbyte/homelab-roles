# roles/monitoring/README.md

Reference for the `monitoring` role.
Explains how the aggregate monitoring layer includes optional focused roles
such as `monitoring_authorized_key`, `monitoring_status`, and
`monitoring_storage_health`, plus the collector companions
`monitoring_docker_tag`, `monitoring_collect`, `monitoring_web`, and
`monitoring_notify`.

## Purpose
- Keep monitoring-related execution order explicit in one aggregate role
- Let consumer inventories opt into SSH transport setup and host status
  generation independently
- Keep dedicated device-health checks separate from the lighter host-status
  summary when inventories want both
- Allow a focused Docker image-tag role to surface safe-versus-review-first
  update guidance without changing the application roles themselves
- Allow one designated host to aggregate monitoring JSON contracts and
  optionally publish a static dashboard through Traefik
- Leave room for future monitoring companions without changing playbook names

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `monitoring_include_authorized_key` | `false` | no | Include `monitoring_authorized_key` in the aggregate layer |
| `monitoring_include_status` | `false` | no | Include `monitoring_status` in the aggregate layer |
| `monitoring_include_storage_health` | `false` | no | Include `monitoring_storage_health` in the aggregate layer |
| `monitoring_include_docker_tag` | `false` | no | Include `monitoring_docker_tag` in the aggregate layer |
| `monitoring_include_collect` | `false` | no | Include `monitoring_collect` in the aggregate layer |
| `monitoring_include_web` | `false` | no | Include `monitoring_web` in the aggregate layer |
| `monitoring_include_notify` | `false` | no | Include `monitoring_notify` in the aggregate layer |

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
monitoring_include_docker_tag: false
monitoring_include_collect: false
monitoring_include_web: false
monitoring_include_notify: false

# group_vars/monitoring/monitoring.yml
monitoring_include_authorized_key: true
monitoring_include_status: true
monitoring_include_storage_health: true
monitoring_include_docker_tag: true

# host_vars/lab/vars.yml
monitoring_include_authorized_key: false
monitoring_include_status: true
monitoring_include_storage_health: true
monitoring_include_docker_tag: true
monitoring_include_collect: true
```

When `monitoring_collect` needs recurring SSH access to remote hosts, keep the
remote public-key setup in `monitoring_authorized_key` and keep any optional
collector private key in `monitoring_collect` itself. That keeps SSH transport
inside the monitoring layer instead of leaking it into `base`. The collector
dashboard can then stay behind the existing Traefik + ACME path while the
collector itself continues to pull the raw `status.json`,
`storage-health.json`, `docker-tag.json`, and `restic-backup.json` contracts
from the monitored hosts. That keeps the dashboard, notifications, and manual
validation flow aligned around the same machine-readable contracts.
If the dashboard was already deployed previously and the current inventory no
longer carries its hostname or basic-auth values, `monitoring_web` can also
adopt the existing live Compose settings through
`monitoring_web_manage_existing_install`.

## Dependencies
None

## License
MIT
