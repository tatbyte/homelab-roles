# roles/base_dns/README.md

Reference for the `base_dns` role.
Explains how the role manages a minimal DNS resolver baseline on Debian-family hosts during the base phase.

## Features
- Validates the requested resolver package, mode, service, DNS servers, and optional search domains
- Installs the resolver package only when the requested resolver service is not already present on the host
- Fully manages `/etc/systemd/resolved.conf` for the `systemd_resolved` mode
- Fully manages a NetworkManager DNS override plus a static `/etc/resolv.conf` for the `networkmanager` mode
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

The `base` role can include `base_dns` when `base_include_dns: true`.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - base_dns
```

Example variables:

```yaml
base_include_dns: true
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
base_dns_service_name: NetworkManager
base_dns_servers:
  - 192.168.0.1
  - 1.1.1.1
```

Use `systemd_resolved` on hosts that actually run `systemd-resolved`.
Use `networkmanager` on hosts whose DNS stack is managed by NetworkManager.
This role intentionally manages only the global resolver baseline for the selected mode.
It does not yet manage DNSSEC policy, per-interface resolver settings, or route-only domains for split-DNS setups.

## Dependencies
None

## License
MIT

## Author
Tatbyte
