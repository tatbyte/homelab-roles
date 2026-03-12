# roles/monitoring_authorized_key/README.md

Reference for the `monitoring_authorized_key` role.
Explains how the role installs an SSH authorized key for monitoring-style inter-host access.

## Purpose
- Allows a specific host (e.g. control) to SSH into other hosts to retrieve information
- Keeps monitoring/backup key management separate from bootstrap

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `monitoring_authorized_key_user` | `root` | no | User account that receives the SSH public key |
| `monitoring_authorized_key_key` | `""` | yes | SSH public key to authorize |

## Usage

```yaml
- hosts: dns
  roles:
    - role: monitoring_authorized_key
```

Set the role inputs in group or host variables for the target hosts:

```yaml
# group_vars/dns/monitoring_authorized_key.yml
monitoring_authorized_key_user: root
monitoring_authorized_key_key: "ssh-ed25519 AAAA... user@control"
```

## Dependencies
None

## Author
tatbyte

## License
MIT
