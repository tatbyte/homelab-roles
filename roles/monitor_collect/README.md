# roles/monitor_collect/README.md

Reference for the `monitor_collect` role.
Explains how this recurring collector pulls JSON monitoring contracts from one
or more declared source hosts, builds one aggregated index, and can optionally
mirror a public JSON tree for consumer roles such as `monitor_web`.

## Purpose
- Keep per-host monitoring contracts local to the monitored hosts
- Pull `status.json`, `storage-health.json`, and `restic-backup.json` into one
  collector host
- Build one machine-readable `index.json` plus an optional public JSON mirror

## Managed Files
- `{{ monitor_collect_script_path }}`: rendered collector runner
- `/etc/systemd/system/{{ monitor_collect_service_unit }}`: oneshot collector service
- `/etc/systemd/system/{{ monitor_collect_timer_unit }}`: recurring schedule
- `{{ monitor_collect_index_path }}`: aggregated collector JSON
- `{{ monitor_collect_public_json_dir }}`: optional public JSON mirror consumed by presentation roles

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `monitor_collect_enabled` | `true` | no | Whether the collector role should be active on the host |
| `monitor_collect_sources` | `[]` | yes when enabled | Declared monitoring sources to collect from |
| `monitor_collect_timer_on_calendar` | `*-*-* *:35:00` | no | systemd calendar expression for the recurring collector timer |
| `monitor_collect_ssh_manage_private_key` | `false` | no | Whether the collector should write and use a dedicated SSH private key for remote sources |
| `monitor_collect_ssh_private_key` | `""` | yes when `monitor_collect_ssh_manage_private_key` is true | OpenSSH private key content written on the collector host |
| `monitor_collect_ssh_identity_file` | `""` | no | Existing SSH identity file path to use when the role should not manage the key directly |
| `monitor_collect_public_json_enabled` | `false` | no | Whether the collector should mirror its aggregated JSON into a public web-readable tree |
| `monitor_collect_public_json_dir` | `{{ monitor_web_publish_dir }}` | no | Destination directory for the public JSON mirror when enabled |

Each source entry supports:

```yaml
- name: dns_1
  display_name: pi4
  ssh_host: 192.168.0.116
  ssh_user: autom8r
  local: false
  status_path: /var/lib/monitor/status.json
  storage_health_path: /var/lib/monitor/storage-health.json
  backup_path: /var/lib/monitor/restic-backup.json
```

For the collector host itself, use `local: true` and omit SSH fields:

```yaml
- name: control
  display_name: elite
  local: true
```

## Notes
- The collector service user must be able to read the monitored JSON
  contracts, which usually means passwordless `sudo` on the source hosts.
- Remote collection uses SSH and expects the declared `ssh_user` to have key
  access from the collector host.
- Keep the remote public-key side in the companion `monitoring_authorized_key`
  role instead of folding it into `base`.
- Use `monitor_collect_ssh_manage_private_key` when you want the collector
  host to receive its dedicated private key from Vault or another secret
  source. Leave it disabled when the collector should reuse an existing
  identity file instead.
- A missing `status.json` still counts as a collector failure. Missing
  `storage-health.json` or `restic-backup.json` on a first rollout degrade the
  source to `warn` until those contracts exist or a cached copy is available.
- The optional dashboard now lives in the companion `monitor_web` role. This
  collector can still mirror `index.json` and the cached per-host contracts
  into a world-readable tree so the web role can serve them without widening
  the permissions of `{{ monitor_collect_output_dir }}` itself.
- The collector keeps the raw `status.json`, `storage-health.json`, and
  `restic-backup.json` cache files per host under
  `{{ monitor_collect_hosts_dir }}` so the dashboard can show both quick
  summaries and contract-specific detail.

## Dependencies
None

## License
MIT
