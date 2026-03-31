# roles/monitoring_web/README.md

Reference for the `monitoring_web` role.
Explains how the role publishes the already-collected monitoring dashboard
through Docker + Traefik while reusing the stable `monitor-collect-web`
project layout on disk.

## Purpose
- Publish the collected monitoring dashboard as a static site
- Keep the homepage focused on fleet summary and quick review counters
- Publish one host-detail page per monitored host under `hosts/<name>/index.html`
- Reuse the existing Docker + Traefik routing pattern without opening a host port
- Keep the presentation layer separate from `monitoring_collect`

## Managed Files
- `{{ monitoring_web_project_dir }}/compose.yml`: Docker Compose project for the dashboard container
- `{{ monitoring_web_project_dir }}/default.conf`: Nginx config used by the dashboard container
- `{{ monitoring_web_publish_dir }}`: published site tree served by the Nginx container
- `{{ monitoring_web_publish_html_path }}`: rendered static dashboard page
- `{{ monitoring_web_host_template_path }}`: generic host-detail page shell copied into each published host directory
- `{{ monitoring_web_manifest_path }}`: PWA manifest
- `{{ monitoring_web_service_worker_path }}`: service worker

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `monitoring_web_enabled` | `true` | no | Whether the dashboard web layer should be active on the host |
| `monitoring_web_manage_existing_install` | `false` | no | Reuse the live Compose hostname/basic-auth settings when the inventory omits them locally |
| `monitoring_web_host` | `""` | yes when enabled | Hostname used by the Traefik router for the dashboard |
| `monitoring_web_proxy_network_name` | `traefik_proxy` | no | External Docker network shared with Traefik |
| `monitoring_web_tls_certresolver` | `letsencrypt` | no | Traefik TLS certresolver name used for the dashboard route |
| `monitoring_web_title` | `Homelab Monitor` | no | Title shown in the dashboard |
| `monitoring_web_short_title` | `Monitor` | no | Short title used by the installable dashboard on mobile home screens |
| `monitoring_web_basic_auth_enabled` | `false` | no | Whether to attach a Traefik basic-auth middleware to the dashboard route |
| `monitoring_web_basic_auth_users` | `[]` | yes when basic auth enabled | List of `user:hash` entries used by Traefik basic auth for the dashboard route |

## Notes
- `monitoring_collect` remains the source-of-truth collector. This role only owns
  the published HTML/PWA assets and the Docker-served web layer.
- The collector still mirrors the public JSON tree into
  `{{ monitoring_web_publish_dir }}` so the dashboard can serve current
  `index.json` and cached per-host contracts without needing extra sync jobs.
- The fleet homepage is intentionally summary-first. Detailed mount, storage,
  backup, and Docker-tag review panels now live on the dedicated host pages.
- The current dashboard expects the collected host objects to expose
  `status`, `storage_health`, `docker_tag`, and `backup` contracts so the UI
  can show both fleet health and container-update guidance in one place.
- The default project, container, and path names intentionally stay on the
  existing `monitor-collect-web` naming so the refactor does not churn a
  working deployment.
- When `monitoring_web_manage_existing_install` is true and the current
  `compose.yml` already exists on the host, the role can recover the live
  dashboard hostname plus Traefik basic-auth users from that file before it
  validates and re-renders the site.

## Dependencies
None

## License
MIT
