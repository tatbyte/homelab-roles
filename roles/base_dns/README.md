# roles/base_dns/README.md

Reference for the `base_dns` role.
Explains how the role manages a minimal DNS resolver baseline on Debian-family hosts during the base phase.

## Features
- Validates the requested resolver package, mode, service, DNS servers, and optional search domains
- Detects the host's current resolver ownership before configuration starts and fails early on clear resolver-mode mismatch or truly ambiguous DNS state
- Installs the resolver package only when the requested resolver service is not already present on the host
- Fully manages `/etc/systemd/resolved.conf` for the `systemd_resolved` mode
- Removes the role-managed NetworkManager DNS override when `systemd_resolved` is selected so `systemd-resolved` stays the single DNS owner
- Fully manages a NetworkManager DNS override plus a static `/etc/resolv.conf` for the `networkmanager` mode
- Stops and disables `systemd-resolved` when `networkmanager` is selected so NetworkManager-backed static resolver state stays the single DNS owner
- Ensures `/etc/resolv.conf` uses the standard `systemd-resolved` stub resolver symlink when `systemd_resolved` is selected
- Ensures the resolver service is enabled and running
- Verifies the managed resolver configuration file, resolver service state, and effective DNS state after changes
- Keeps the role intentionally narrow by not managing DNSSEC, split-DNS policy, or per-interface resolver logic beyond the selected global resolver mode

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_dns_packages` | derived from `base_dns_resolver_mode` | no | Resolver package list installed only when the requested resolver service is absent; defaults to `['systemd-resolved']` for `systemd_resolved` and `[]` for `networkmanager` |
| `base_dns_service_name` | derived from `base_dns_resolver_mode` | no | Resolver service name enabled, restarted, and validated by the role; defaults to `systemd-resolved` for `systemd_resolved` and `NetworkManager` for `networkmanager` |
| `base_dns_resolver_mode` | `systemd_resolved` | no | Resolver backend managed by the role; supports `systemd_resolved` and `networkmanager` |
| `base_dns_servers` | `[]` | yes | DNS server list written to the managed `DNS=` line; must contain at least one server value |
| `base_dns_search_domains` | `[]` | no | Optional search domains written to `Domains=` or `search`; route-only split-DNS prefixes such as `~example.internal` are intentionally rejected |

## Usage

The aggregate `base` role reads `base_dns_enabled` from the role-scoped base
vars file.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - base_dns
```

Example variables:

```yaml
base_dns_enabled: true
base_dns_resolver_mode: systemd_resolved
base_dns_servers:
  - 192.168.0.1
  - 1.1.1.1
base_dns_search_domains:
  - lab.home.arpa
```

NetworkManager-backed hosts can override the mode per host:

```yaml
base_dns_resolver_mode: networkmanager
base_dns_servers:
  - 192.168.0.1
  - 1.1.1.1
```

Choose `base_dns_resolver_mode` manually after checking the host's current
resolver stack. Useful commands:

```sh
ls -l /etc/resolv.conf
systemctl is-active systemd-resolved
systemctl is-active NetworkManager
nmcli device show eth0 | grep -i 'IP4.DNS\|IP6.DNS'
resolvectl status
```

Interpret them conservatively:

- stub symlink plus active `systemd-resolved` plus working `resolvectl` usually means `systemd_resolved`
- regular `/etc/resolv.conf` or a common NetworkManager-owned resolver symlink plus active `NetworkManager` usually means `networkmanager`
- mixed states can be converged by this role to the requested mode, but truly unclear signals should still be fixed manually first

Use `systemd_resolved` on hosts that actually run `systemd-resolved`.
Use `networkmanager` on hosts that keep `/etc/resolv.conf` as a regular file
while NetworkManager owns the underlying network stack for that machine.
This role converges the host to one DNS owner:

- `systemd_resolved` keeps the stub symlink in place and removes the role-managed NetworkManager DNS override when present
- `networkmanager` keeps a static managed `/etc/resolv.conf` and stops/disables `systemd-resolved`

This role intentionally manages only the global resolver baseline for the selected mode.
It does not yet manage DNSSEC policy, per-interface resolver settings, or route-only domains for split-DNS setups.

When the requested mode does not match a clear single-owner detected host
state, the role fails before configuration and prints the
`base_dns_resolver_mode` value to use. Mixed but convergeable states are
allowed to continue so the role can clean up the conflicting owner during the
config phase.

## Dependencies
None

## License
MIT

## Author
Tatbyte
