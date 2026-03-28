# roles/monitoring/README.md

Reference for the `monitoring` role.
Explains how the aggregate monitoring layer includes optional focused roles
such as `monitoring_authorized_key` and `monitoring_status`.

## Purpose
- Keep monitoring-related execution order explicit in one aggregate role
- Let consumer inventories opt into SSH transport setup and host status
  generation independently
- Leave room for future monitoring companions without changing playbook names

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `monitoring_include_authorized_key` | `false` | no | Include `monitoring_authorized_key` in the aggregate layer |
| `monitoring_include_status` | `false` | no | Include `monitoring_status` in the aggregate layer |

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

# group_vars/monitoring/monitoring.yml
monitoring_include_status: true

# host_vars/lab/vars.yml
monitoring_include_status: false
```

## Dependencies
None

## License
MIT
