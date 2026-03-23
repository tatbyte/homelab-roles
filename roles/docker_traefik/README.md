# roles/docker_traefik/README.md

Reference for the `docker_traefik` role.
Explains how the role manages a Traefik reverse proxy through Docker Compose with ACME DNS challenge support, role-owned access identities, and `/srv`-based persistence on Debian-family hosts.

## Features
- Installs requested or auto-detected Docker Compose support packages with APT
- Supports either `docker compose` or classic `docker-compose` through a configurable command prefix
- Creates a role-owned service user and feature access group for Traefik host files
- Adds requested existing admin users to the role-owned Traefik access group
- Manages a Docker Compose Traefik project under a fixed `/srv` project directory
- Renders a static `traefik.yml` configuration file from a Jinja template
- Renders a dynamic dashboard-only configuration file from a Jinja template
- Renders a secret-bearing environment file from Vault-backed variables
- Uses ACME DNS challenge for Let's Encrypt certificate issuance
- Creates a stable Docker network name so other Compose projects can join it
- Optionally registers managed firewall rules for HTTP and HTTPS
- Verifies package, rendered-file, network, and running service state after changes

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `docker_traefik_enabled` | `true` | no | Enables Traefik package, file, and Docker Compose management |
| `docker_traefik_packages` | `[]` | no | Explicit package list installed to support the chosen Compose command; when empty, the role auto-detects an available package |
| `docker_traefik_compose_package_candidates` | inherits `docker_engine_compose_package_candidates` or `['docker-compose-plugin', 'docker-compose-v2', 'docker-compose']` fallback | no | Candidate package names probed when auto-detecting Compose support on Debian-family hosts; inherit the engine package-family preference when available |
| `docker_traefik_compose_command` | `['docker', 'compose']` | no | Command prefix used for Compose operations such as `up`, `down`, `ps`, and `version`; override with `['docker-compose']` on hosts that use the classic Compose binary |
| `docker_traefik_project_dir` | `/srv/traefik` | no | Directory that stores the managed Compose project files |
| `docker_traefik_data_dir` | `/srv/traefik/data` | no | Directory that stores Traefik persistent data for backup-friendly restores |
| `docker_traefik_service_user` | `srv_traefik` | no | Role-owned service user that owns Traefik data paths on the host |
| `docker_traefik_access_group` | `access_traefik` | no | Role-owned feature access group used for Traefik host access |
| `docker_traefik_access_group_members` | de-duplicated `bootstrap_user` / `user_account_name` list with `admin` fallback | no | Existing admin users that should receive Traefik host access when present |
| `docker_traefik_image` | `traefik:v3.0` | no | Container image used for the managed Traefik service |
| `docker_traefik_network_name` | `traefik_proxy` | no | Stable Docker network name other Compose projects can join |
| `docker_traefik_acme_email` | `admin@example.com` | yes | Email address used for Let's Encrypt ACME registration |
| `docker_traefik_dns_challenge_provider` | `cloudflare` | yes | Traefik DNS challenge provider name |
| `docker_traefik_dns_env` | `{}` | yes | Environment variables passed to Traefik for the DNS provider credentials |
| `docker_traefik_dashboard_host` | `traefik.example.com` | yes when dashboard enabled | Host name used for the Traefik dashboard router; examples can derive this from the inventory `alias` plus a Vault-backed shared domain suffix |
| `docker_traefik_dashboard_basic_auth_users` | `[]` | yes when dashboard enabled | List of `user:hash` entries used by Traefik basic auth for the dashboard |
| `docker_traefik_manage_firewall_rules` | `true` | no | Whether to register managed HTTP and HTTPS firewall rules |

## Usage

The aggregate `docker` role can include `docker_traefik` when
`docker_include_traefik: true`.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - docker_engine
    - docker_traefik
```

Minimal example variables:

```yaml
docker_traefik_project_dir: /srv/traefik
docker_traefik_service_user: srv_traefik
docker_traefik_access_group: access_traefik
docker_traefik_access_group_members: >-
  {{
    [
      bootstrap_user,
      user_account_name
    ]
    | map('trim')
    | reject('equalto', '')
    | unique
    | list
  }}
docker_traefik_acme_email: "{{ vault_docker_traefik_acme_email }}"
docker_traefik_dns_challenge_provider: cloudflare
docker_traefik_dns_env:
  CF_DNS_API_TOKEN: "{{ vault_docker_traefik_dns_api_token }}"
docker_public_host_alias: "{{ alias | default(inventory_hostname) }}"
docker_public_domain_suffix: "{{ vault_docker_public_domain_suffix }}"
docker_traefik_dashboard_host: "traefik.{{ docker_public_host_alias }}.{{ docker_public_domain_suffix }}"
docker_traefik_dashboard_basic_auth_users: "{{ vault_docker_traefik_dashboard_basic_auth_users }}"
docker_traefik_firewall_rules:
  - rule: allow
    direction: in
    port: "80"
    proto: tcp
    comment: "managed:docker_traefik:http"
  - rule: allow
    direction: in
    port: "443"
    proto: tcp
    comment: "managed:docker_traefik:https"
```

Other Docker Compose projects can join the same proxy network with a stable
external network reference such as:

```yaml
networks:
  traefik_proxy:
    external: true
    name: "{{ docker_traefik_network_name }}"
```

Then label the application service for Traefik as needed, while keeping this
role's file-provider dynamic config limited to the Traefik dashboard.

## Compose Conventions

Future Docker application roles should keep Compose invocation configurable
instead of assuming plugin-style `docker compose` is always available.
Use `docker_traefik_compose_command` on hosts that need classic
`docker-compose`, and keep the selected Compose package in the same package
family as the Docker engine package on that host.

Keep persistent service data under `{{ docker_traefik_project_dir }}/data`
so backups of `/srv` capture the full Traefik host-side state needed for host
recreation and certificate recovery.

## Firewall Integration

This role registers HTTP and HTTPS rules into `base_firewall_role_declared_rules`
when `docker_traefik_manage_firewall_rules: true`.
If you use `base_firewall`, re-run that role after `docker_traefik` has
registered its rules, or run the Traefik role before `base_firewall`.

## Dependencies
None

## License
MIT

## Author
Tatbyte
