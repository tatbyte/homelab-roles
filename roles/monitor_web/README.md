# roles/monitor_web/README.md

Reference for the `monitor_web` role.
Explains how the role publishes the already-collected monitoring dashboard
through Docker + Traefik while reusing the stable `monitor-collect-web`
project layout on disk.

## Purpose
- Publish the collected monitoring dashboard as a static site
- Reuse the existing Docker + Traefik routing pattern without opening a host port
- Keep the presentation layer separate from `monitor_collect`

## Managed Files
- `{{ monitor_web_project_dir }}/compose.yml`: Docker Compose project for the dashboard container
- `{{ monitor_web_project_dir }}/default.conf`: Nginx config used by the dashboard container
- `{{ monitor_web_publish_dir }}`: published site tree served by the Nginx container
- `{{ monitor_web_publish_html_path }}`: rendered static dashboard page
- `{{ monitor_web_manifest_path }}`: PWA manifest
- `{{ monitor_web_service_worker_path }}`: service worker

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `monitor_web_enabled` | `true` | no | Whether the dashboard web layer should be active on the host |
| `monitor_web_host` | `""` | yes when enabled | Hostname used by the Traefik router for the dashboard |
| `monitor_web_proxy_network_name` | `traefik_proxy` | no | External Docker network shared with Traefik |
| `monitor_web_tls_certresolver` | `letsencrypt` | no | Traefik TLS certresolver name used for the dashboard route |
| `monitor_web_title` | `Homelab Monitor` | no | Title shown in the dashboard |
| `monitor_web_short_title` | `Monitor` | no | Short title used by the installable dashboard on mobile home screens |
| `monitor_web_basic_auth_enabled` | `false` | no | Whether to attach a Traefik basic-auth middleware to the dashboard route |
| `monitor_web_basic_auth_users` | `[]` | yes when basic auth enabled | List of `user:hash` entries used by Traefik basic auth for the dashboard route |

## Notes
- `monitor_collect` remains the source-of-truth collector. This role only owns
  the published HTML/PWA assets and the Docker-served web layer.
- The collector still mirrors the public JSON tree into
  `{{ monitor_web_publish_dir }}` so the dashboard can serve current
  `index.json` and cached per-host contracts without needing extra sync jobs.
- The default project, container, and path names intentionally stay on the
  existing `monitor-collect-web` naming so the refactor does not churn a
  working deployment.

## Dependencies
None

## License
MIT
