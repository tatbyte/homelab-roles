# roles/docker_adguard_sync/README.md

Reference for the `docker_adguard_sync` role.
Explains how the role manages `adguardhome-sync` through Docker Compose with a
Traefik-connected HTTPS UI, shared AdGuard access identities, and Vault-backed
origin, replica, and API credentials on Debian-family hosts.

## Features
- Installs requested or auto-detected Docker Compose support packages with APT
- Supports either `docker compose` or classic `docker-compose` through a configurable command prefix
- Reuses the AdGuard service user and access group by default so host permissions stay aligned across both services
- Adds requested existing admin users to the shared AdGuard access group when present
- Manages an `adguardhome-sync` Docker Compose project under a fixed `/srv/adguard-sync` project directory
- Renders a managed YAML config file for the sync schedule, origin, replicas, feature toggles, and API login
- Publishes the `adguardhome-sync` web UI through Traefik on the shared proxy network
- Verifies package, rendered-file, proxy-network, and running service state after changes

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `docker_adguard_sync_enabled` | `true` | no | Enables `adguardhome-sync` package, file, and Docker Compose management |
| `docker_adguard_sync_packages` | `docker_adguard_packages` or `[]` | no | Explicit package list installed to support the chosen Compose command; when empty, the role auto-detects an available package |
| `docker_adguard_sync_compose_package_candidates` | inherits `docker_adguard_compose_package_candidates` or the engine candidate list fallback | no | Candidate package names probed when auto-detecting Compose support on Debian-family hosts; inherit the AdGuard and engine package-family preference when available |
| `docker_adguard_sync_compose_command` | `docker_adguard_compose_command` or `['docker', 'compose']` | no | Command prefix used for Compose operations such as `up`, `down`, `ps`, and `version`; override with `['docker-compose']` on hosts that use the classic Compose binary |
| `docker_adguard_sync_project_dir` | `/srv/adguard-sync` | no | Directory that stores the managed Compose project files |
| `docker_adguard_sync_data_dir` | `/srv/adguard-sync/data` | no | Directory that stores the managed `adguardhome-sync` config file |
| `docker_adguard_sync_service_user` | `docker_adguard_service_user` or `srv_adguard` | no | Shared AdGuard-owned service user that owns the sync data path on the host |
| `docker_adguard_sync_access_group` | `docker_adguard_access_group` or `access_adguard` | no | Shared AdGuard feature access group used for sync host access |
| `docker_adguard_sync_access_group_members` | shared `docker_adguard_access_group_members` or a de-duplicated `bootstrap_user` / `user_account_name` list with `admin` fallback | no | Existing admin users that should receive shared AdGuard host access when present |
| `docker_adguard_sync_container_user` | `"<service_uid>:<access_gid>"` | no | Numeric container user/group applied in Compose so the sync process can read the shared host-mounted config without opening it to all users |
| `docker_adguard_sync_host` | `adguard-sync.example.com` | yes | Host name used by the Traefik router labels for the `adguardhome-sync` UI |
| `docker_adguard_sync_origin` | `{'url': '', 'username': 'admin', 'password': ''}` | yes | Mapping that defines the origin AdGuard Home API endpoint and login |
| `docker_adguard_sync_replicas` | `[]` | yes | List of replica mappings with `url`, `username`, and `password` entries |
| `docker_adguard_sync_api_username` | `admin` | yes | UI/API login username for `adguardhome-sync`; best sourced from Vault |
| `docker_adguard_sync_api_password` | `''` | yes | UI/API login password for `adguardhome-sync`; best sourced from Vault |
| `docker_adguard_sync_cron` | `"0 */6 * * *"` | no | Cron expression used by the sync daemon |
| `docker_adguard_sync_api_metrics_scrape_interval` | `"60s"` | no | Metrics scrape interval rendered as a duration string accepted by the pinned `adguardhome-sync` image |
| `docker_adguard_sync_features` | all supported feature toggles enabled | no | Mapping of feature toggles rendered into the managed YAML config |

## Usage

The aggregate `docker` role can include `docker_adguard_sync` when
`docker_include_adguard_sync: true`.
The aggregate include is tagged with both `docker_adguard_sync` and
`docker_adguard`, so hosts that enable sync can still converge it during an
AdGuard-focused tagged run.
Run it after both `docker_traefik` and `docker_adguard` so the shared external
proxy network already exists and the target AdGuard instances are already
reachable on their LAN HTTP bind ports.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - docker_engine
    - docker_traefik
    - docker_adguard
    - docker_adguard_sync
```

Minimal example variables:

```yaml
docker_adguard_sync_project_dir: /srv/adguard-sync
docker_adguard_sync_service_user: "{{ docker_adguard_service_user }}"
docker_adguard_sync_access_group: "{{ docker_adguard_access_group }}"
docker_adguard_sync_access_group_members: "{{ docker_adguard_access_group_members }}"
docker_adguard_sync_proxy_network_name: "{{ docker_traefik_network_name }}"
docker_adguard_sync_host: "adguard-sync.{{ docker_public_host_alias }}.{{ docker_public_domain_suffix }}"
docker_adguard_sync_origin:
  url: "http://{{ vault_docker_adguard_sync_origin_ip }}:{{ docker_adguard_http_bind_port }}"
  username: "{{ docker_adguard_admin_credentials.split(':', 1)[0] }}"
  password: "{{ vault_docker_adguard_sync_adguard_password }}"
docker_adguard_sync_replicas:
  - url: "http://{{ vault_docker_adguard_sync_replica_ip }}:{{ docker_adguard_http_bind_port }}"
    username: "{{ docker_adguard_admin_credentials.split(':', 1)[0] }}"
    password: "{{ vault_docker_adguard_sync_adguard_password }}"
docker_adguard_sync_api_username: "{{ vault_docker_adguard_sync_api_username }}"
docker_adguard_sync_api_password: "{{ vault_docker_adguard_sync_api_password }}"
```

This role intentionally keeps the sync UI behind Traefik while letting the
managed sync process talk to each AdGuard instance over its direct LAN IP plus
the AdGuard HTTP bind port. That split keeps browser access on HTTPS while
avoiding public-name dependency for the internal sync traffic.
By default the container also runs with the shared AdGuard UID/GID on the host
so the bind-mounted config can stay group-readable instead of world-readable.
The pinned `v0.7.8` image accepts the feature set rendered by this role, so the
managed config intentionally omits newer schema keys that image does not
understand.

## Compose Conventions

Future Docker application roles should keep Compose invocation configurable
instead of assuming plugin-style `docker compose` is always available.
Use `docker_adguard_sync_compose_command` on hosts that need classic
`docker-compose`, and keep the selected Compose package in the same package
family as the Docker engine package on that host. If a host already overrides
`docker_adguard_compose_command` or other Docker child-role Compose settings in
`host_vars/<host>/vars.yml`, add matching `docker_adguard_sync_packages` and
`docker_adguard_sync_compose_command` there too before enabling sync so all
Compose-managed services on that host follow the same invocation path.

## Dependencies
None

## License
MIT

## Author
Tatbyte
