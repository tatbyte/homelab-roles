# roles/base_dns/README.md

Reference for the `base_dns` role.
Explains how the role manages a minimal DNS resolver baseline on Debian-family hosts during the base phase.

## Features
- Validates the requested resolver package, mode, service, DNS servers, and optional search domains
- Installs the resolver package only when the requested resolver service is not already present on the host
- Fully manages `/etc/systemd/resolved.conf` for the supported `systemd_resolved` mode
- Ensures `/etc/resolv.conf` uses the standard `systemd-resolved` stub resolver symlink
- Ensures the resolver service is enabled and running
- Verifies the managed resolver configuration file, stub-resolver symlink, service state, and active resolver values after changes
- Keeps v1 intentionally narrow by not managing DNSSEC, split-DNS policy, or per-interface resolver logic

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_dns_packages` | `['systemd-resolved']` | no | Resolver package list installed only when the requested resolver service is absent |
| `base_dns_service_name` | `systemd-resolved` | no | Resolver service name enabled, restarted, and validated by the role |
| `base_dns_resolver_mode` | `systemd_resolved` | no | Resolver backend managed by the role; v1 supports only `systemd_resolved` |
| `base_dns_servers` | `[]` | yes | DNS server list written to the managed `DNS=` line; must contain at least one server value |
| `base_dns_search_domains` | `[]` | no | Optional search domains written to `Domains=`; route-only split-DNS prefixes such as `~example.internal` are intentionally rejected in v1 |

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

This role intentionally manages only the global resolver baseline through `systemd-resolved`.
It does not yet manage DNSSEC policy, per-interface resolver settings, or route-only domains for split-DNS setups.

## Dependencies
None

## License
MIT

## Author
Tatbyte
