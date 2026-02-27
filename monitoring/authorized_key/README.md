# monitoring/authorized_key Role

Adds an SSH authorized key for inter-host access (monitoring, alerting, backup, status retrieval).

## Purpose
- Allows a specific host (e.g. control) to SSH into other hosts to retrieve information
- Keeps monitoring/backup key management separate from bootstrap

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `monitoring_authorized_user` | `bootstrap_user` or `root` | no | User to add the key to |
| `monitoring_authorized_key` | `""` | yes | SSH public key to authorize |

## Usage

```yaml
- hosts: dns
  roles:
    - monitoring/authorized_key
```

Set `monitoring_authorized_key` in group_vars for the target hosts:

```yaml
# group_vars/dns/vars.yml
monitoring_authorized_key: "ssh-ed25519 AAAA... user@control"
```

## Dependencies
None

## Author
tatbyte

## License
MIT
