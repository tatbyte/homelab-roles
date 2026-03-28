# roles/monitor_collect/README.md

Reference for the `monitor_collect` role.
Explains how this recurring collector pulls JSON monitoring contracts from one
or more declared source hosts, builds one aggregated index, and can optionally
publish a static dashboard through Docker and Traefik for quick inspection.

## Purpose
- Keep per-host monitoring contracts local to the monitored hosts
- Pull `status.json`, `storage-health.json`, and `restic-backup.json` into one
  collector host
- Build one machine-readable `index.json` plus an optional static dashboard

## Managed Files
- `{{ monitor_collect_script_path }}`: rendered collector runner
- `/etc/systemd/system/{{ monitor_collect_service_unit }}`: oneshot collector service
- `/etc/systemd/system/{{ monitor_collect_timer_unit }}`: recurring schedule
- `{{ monitor_collect_index_path }}`: aggregated collector JSON
- `{{ monitor_collect_web_html_path }}`: rendered static dashboard page
- `{{ monitor_collect_web_project_dir }}/compose.yml`: optional dashboard Compose project
- `{{ monitor_collect_web_project_dir }}/default.conf`: optional Nginx config for the dashboard container
- `{{ monitor_collect_web_publish_dir }}`: published static dashboard tree served by the Nginx container

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `monitor_collect_enabled` | `true` | no | Whether the collector role should be active on the host |
| `monitor_collect_sources` | `[]` | yes when enabled | Declared monitoring sources to collect from |
| `monitor_collect_timer_on_calendar` | `*-*-* *:35:00` | no | systemd calendar expression for the recurring collector timer |
| `monitor_collect_ssh_manage_private_key` | `false` | no | Whether the collector should write and use a dedicated SSH private key for remote sources |
| `monitor_collect_ssh_private_key` | `""` | yes when `monitor_collect_ssh_manage_private_key` is true | OpenSSH private key content written on the collector host |
| `monitor_collect_ssh_identity_file` | `""` | no | Existing SSH identity file path to use when the role should not manage the key directly |
| `monitor_collect_web_enabled` | `false` | no | Whether to publish the collected dashboard through an Nginx container on the Traefik proxy network |
| `monitor_collect_web_host` | `""` | yes when `monitor_collect_web_enabled` is true | Hostname used by the Traefik router for the dashboard |
| `monitor_collect_web_proxy_network_name` | `traefik_proxy` | no | External Docker network shared with Traefik |
| `monitor_collect_web_tls_certresolver` | `letsencrypt` | no | Traefik TLS certresolver name used for the dashboard route |
| `monitor_collect_web_title` | `Homelab Monitor` | no | Title shown in the dashboard |
| `monitor_collect_web_short_title` | `Monitor` | no | Short title used by the installable dashboard on mobile home screens |
| `monitor_collect_web_basic_auth_enabled` | `false` | no | Whether to attach a Traefik basic-auth middleware to the dashboard route |
| `monitor_collect_web_basic_auth_users` | `[]` | yes when basic auth enabled | List of `user:hash` entries used by Traefik basic auth for the dashboard route |

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
- The optional dashboard stays fully static: the collector keeps its private
  state under `{{ monitor_collect_output_dir }}`, then republishes
  world-readable copies under `{{ monitor_collect_web_publish_dir }}` for the
  lightweight Nginx container that joins the existing Traefik proxy network.
- The dashboard also ships with a web manifest, a service worker, a generated
  SVG icon, and raster PNG app icons so modern browsers have a cleaner path to
  install it as a lightweight PWA on phones or tablets.
- When you want route protection, prefer `monitor_collect_web_basic_auth_users`
  with Traefik `user:hash` values instead of container-local plaintext
  passwords.
- The collector keeps the raw `status.json`, `storage-health.json`, and
  `restic-backup.json` cache files per host under
  `{{ monitor_collect_hosts_dir }}` so the dashboard can show both quick
  summaries and contract-specific detail.

## Dependencies
None

## License
MIT
