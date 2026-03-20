# roles/docker_wireguard/README.md

Reference for the `docker_wireguard` role.
Explains how the role manages `wg-easy` through Docker Compose with a
Traefik-connected HTTPS dashboard, Vault-backed initial admin inputs, a direct
WireGuard UDP listener, and `/srv`-based persistence on Debian-family hosts.

## Features
- Installs requested or auto-detected Docker Compose support packages with APT
- Creates a role-owned service user and feature access group for WireGuard host files
- Adds requested existing admin users to the role-owned WireGuard access group
- Manages a Docker Compose WireGuard project under a fixed `/srv` project directory
- Keeps `wg-easy` state under `/srv/wireguard/data` through the `/etc/wireguard` bind mount
- Renders a Vault-friendly environment file for initial admin username, password, and host setup
- Renders a Docker Compose file for `wg-easy` v15 with Traefik labels on the shared proxy network
- Optionally registers a managed UDP firewall rule for the VPN listener
- Verifies package, rendered-file, proxy-network, and running service state after changes

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `docker_wireguard_enabled` | `true` | no | Enables WireGuard package, file, and Docker Compose management |
| `docker_wireguard_packages` | `[]` | no | Explicit package list installed to support `docker compose`; when empty, the role auto-detects an available package |
| `docker_wireguard_project_dir` | `/srv/wireguard` | no | Directory that stores the managed Compose project files |
| `docker_wireguard_data_dir` | `/srv/wireguard/data` | no | Directory that stores persistent `wg-easy` state for backup-friendly restores |
| `docker_wireguard_service_user` | `srv_wireguard` | no | Role-owned service user that owns WireGuard data paths on the host |
| `docker_wireguard_access_group` | `access_wireguard` | no | Role-owned feature access group used for WireGuard host access |
| `docker_wireguard_access_group_members` | de-duplicated `bootstrap_user` / `user_account_name` list with `admin` fallback | no | Existing admin users that should receive WireGuard host access when present |
| `docker_wireguard_host` | `wireguard.example.com` | yes | Public host name used both by the `wg-easy` initial setup and the Traefik router rule |
| `docker_wireguard_web_ui_enabled` | `true` | no | When `true`, publish the `wg-easy` dashboard through Traefik; when `false`, omit Traefik exposure and bind the UI to container-local `127.0.0.1` |
| `docker_wireguard_admin_username` | `admin` | yes when `docker_wireguard_init_enabled` | Initial `wg-easy` admin username; best sourced from Vault |
| `docker_wireguard_admin_password` | `''` | yes when `docker_wireguard_init_enabled` | Initial `wg-easy` admin password; best sourced from Vault |
| `docker_wireguard_init_dns` | `[]` | no | Optional global DNS list passed to `wg-easy` first-start setup as `INIT_DNS`; use IPs and provide multiple servers as a comma-separated list through the template |
| `docker_wireguard_vpn_bind_port` | `51820` | no | Host UDP port published for WireGuard client connections |
| `docker_wireguard_container_web_port` | `51821` | no | Internal TCP port used by the `wg-easy` web UI and Traefik service labels |
| `docker_wireguard_proxy_network_name` | `docker_traefik_network_name` or `traefik_proxy` fallback | no | External Docker network name created by Traefik and joined by `wg-easy` |
| `docker_wireguard_cap_add` | `['NET_ADMIN', 'SYS_MODULE']` | no | Linux capabilities granted to the container for WireGuard interface and module handling |
| `docker_wireguard_manage_firewall_rules` | `true` | no | Whether to register a managed VPN UDP firewall rule |

## Usage

The aggregate `docker` role can include `docker_wireguard` when
`docker_include_wireguard: true`.
Run it after `docker_traefik` so the shared external proxy network already
exists before the `wg-easy` container starts.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - docker_engine
    - docker_traefik
    - docker_wireguard
```

Minimal example variables:

```yaml
docker_wireguard_project_dir: /srv/wireguard
docker_wireguard_data_dir: "{{ docker_wireguard_project_dir }}/data"
docker_wireguard_service_user: srv_wireguard
docker_wireguard_access_group: access_wireguard
docker_wireguard_access_group_members: >-
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
docker_wireguard_proxy_network_name: "{{ docker_traefik_network_name }}"
docker_wireguard_host: "{{ vault_docker_wireguard_host }}"
docker_wireguard_web_ui_enabled: true
docker_wireguard_admin_username: "{{ vault_docker_wireguard_admin_username }}"
docker_wireguard_admin_password: "{{ vault_docker_wireguard_admin_password }}"
docker_wireguard_init_dns: "{{ vault_docker_wireguard_init_dns | to_json | from_json }}"
docker_wireguard_vpn_bind_port: 51820
docker_wireguard_firewall_rules:
  - rule: allow
    direction: in
    port: "{{ docker_wireguard_vpn_bind_port | string }}"
    proto: udp
    comment: "managed:docker_wireguard:vpn-udp"
```

This role renders `wireguard.env` from role variables, so environment-specific
and secret-bearing values such as the public host, initial admin username, and
initial admin password can come from Vault-backed vars cleanly.
If you want clients to use specific DNS resolvers while connected, set
`docker_wireguard_init_dns` to a list of resolver IPs. The template renders
that as the upstream-documented `INIT_DNS` first-start value.
If you set `docker_wireguard_web_ui_enabled: false`, the role stops attaching
Traefik labels and binds the UI to `127.0.0.1` inside the container so the web
dashboard is not externally reachable until you re-enable it.

Keep persistent service data under `{{ docker_wireguard_data_dir }}` so backups
of `/srv` capture the `wg-easy` database and WireGuard host-side state needed
for host recreation.

## Initial Setup Caveat

The official `wg-easy` unattended-setup vars are only consumed on the first
start of a fresh data directory.
That means changing `docker_wireguard_admin_username`,
`docker_wireguard_admin_password`, or `docker_wireguard_host` later does not
re-seed an already initialized `wg-easy` database automatically.
For an existing deployment, use the `wg-easy` UI or CLI to rotate credentials,
or recreate the data directory when you intentionally want a fresh initial
setup.

## Firewall Integration

This role registers a UDP VPN rule into `base_firewall_role_declared_rules`
when `docker_wireguard_manage_firewall_rules: true`.
If you use `base_firewall`, re-run that role after `docker_wireguard` has
registered its rules, or run the WireGuard role before `base_firewall`.

## Dependencies
None

## License
MIT

## Author
Tatbyte
