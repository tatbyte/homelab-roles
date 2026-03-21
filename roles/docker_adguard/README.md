# roles/docker_adguard/README.md

Reference for the `docker_adguard` role.
Explains how the role manages AdGuard Home through Docker Compose with a
Traefik-connected proxy-network deployment, role-owned access identities, and
`/srv`-based persistence on Debian-family hosts.

## Features
- Installs requested or auto-detected Docker Compose support packages with APT
- Creates a role-owned service user and feature access group for AdGuard host files
- Adds requested existing admin users to the role-owned AdGuard access group
- Manages a Docker Compose AdGuard Home project under a fixed `/srv` project directory
- Bootstraps `AdGuardHome.yaml` from a Jinja template on first run, then merges later role-owned setting updates while preserving unrelated AdGuard-managed fields and non-managed users
- Renders a Docker Compose file that publishes Traefik routing through Compose labels
- Reuses the external Traefik proxy network so the web UI stays behind the reverse proxy
- Optionally registers managed DNS firewall rules for TCP and UDP on the configured host DNS port
- Verifies package, rendered-file, network, and running service state after changes

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `docker_adguard_enabled` | `true` | no | Enables AdGuard package, file, and Docker Compose management |
| `docker_adguard_packages` | `[]` | no | Explicit package list installed to support `docker compose`; when empty, the role auto-detects an available package |
| `docker_adguard_project_dir` | `/srv/adguard` | no | Directory that stores the managed Compose project files |
| `docker_adguard_data_dir` | `/srv/adguard/data` | no | Directory that stores AdGuard persistent data for backup-friendly restores |
| `docker_adguard_service_user` | `srv_adguard` | no | Role-owned service user that owns AdGuard data paths on the host |
| `docker_adguard_access_group` | `access_adguard` | no | Role-owned feature access group used for AdGuard host access |
| `docker_adguard_access_group_members` | de-duplicated `bootstrap_user` / `user_account_name` list with `admin` fallback | no | Existing admin users that should receive AdGuard host access when present |
| `docker_adguard_proxy_network_name` | `docker_traefik_network_name` or `traefik_proxy` fallback | no | External Docker network name created by Traefik and joined by AdGuard |
| `docker_adguard_host` | `adguard.example.com` | yes | Host name used by the Traefik router labels for the AdGuard web UI; examples can derive this from the inventory `alias` plus a Vault-backed shared domain suffix |
| `docker_adguard_admin_user` | `admin` | no | Admin account name written into the managed AdGuard configuration |
| `docker_adguard_admin_password_hash` | `''` | yes | AdGuard-compatible bcrypt hash for the managed admin account |
| `docker_adguard_dns_bind_port` | `53` | no | Host DNS port published by the AdGuard container for TCP and UDP |
| `docker_adguard_container_dns_port` | `53` | no | Internal DNS port that AdGuard listens on inside the container |
| `docker_adguard_manage_firewall_rules` | `true` | no | Whether to register managed DNS firewall rules |

## Usage

The aggregate `docker` role can include `docker_adguard` when
`docker_include_adguard: true`.
Run it after `docker_traefik` so the shared external proxy network already
exists before AdGuard Compose startup.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - docker_engine
    - docker_traefik
    - docker_adguard
```

Minimal example variables:

```yaml
docker_adguard_project_dir: /srv/adguard
docker_adguard_service_user: srv_adguard
docker_adguard_access_group: access_adguard
docker_adguard_access_group_members: >-
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
docker_adguard_proxy_network_name: "{{ docker_traefik_network_name }}"
docker_public_host_alias: "{{ alias | default(inventory_hostname) }}"
docker_public_domain_suffix: "{{ vault_docker_public_domain_suffix }}"
docker_adguard_host: "adguard.{{ docker_public_host_alias }}.{{ docker_public_domain_suffix }}"
docker_adguard_admin_password_hash: "{{ vault_docker_adguard_admin_password_hash }}"
docker_adguard_dns_bind_port: 5353
docker_adguard_container_dns_port: 53
docker_adguard_firewall_rules:
  - rule: allow
    direction: in
    port: "{{ docker_adguard_dns_bind_port | string }}"
    proto: tcp
    comment: "managed:docker_adguard:dns-tcp"
  - rule: allow
    direction: in
    port: "{{ docker_adguard_dns_bind_port | string }}"
    proto: udp
    comment: "managed:docker_adguard:dns-udp"
```

This role keeps Traefik routing local to the AdGuard Compose file through
service labels, so no extra Traefik file-provider dynamic config is needed for
the AdGuard web UI.

Keep persistent service data under `{{ docker_adguard_project_dir }}/data` so
backups of `/srv` capture the full AdGuard host-side state needed for host
recreation.

## Firewall Integration

This role registers DNS firewall rules into `base_firewall_role_declared_rules`
when `docker_adguard_manage_firewall_rules: true`.
If you use `base_firewall`, re-run that role after `docker_adguard` has
registered its rules, or run the AdGuard role before `base_firewall`.

## Dependencies
None

## License
MIT

## Author
Tatbyte
