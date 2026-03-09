# roles/base_ntp/README.md

Reference for the `base_ntp` role.
Explains how the role configures system time synchronization on Debian-family hosts during the base phase.

## Features
- Installs the NTP client package with APT before time synchronization configuration
- Validates the requested NTP package, service, and server list inputs
- Fully manages `/etc/systemd/timesyncd.conf` through a template
- Ensures the NTP service is enabled and running
- Verifies the managed configuration file and service state after changes

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_ntp_packages` | `['systemd-timesyncd']` | no | Package list installed with APT to provide the NTP client |
| `base_ntp_service_name` | `systemd-timesyncd` | no | Service name enabled, restarted, and validated by the role |
| `base_ntp_servers` | `['0.pool.ntp.org', '1.pool.ntp.org', '2.pool.ntp.org', '3.pool.ntp.org']` | no | NTP servers written to the managed `NTP=` line |
| `base_ntp_fallback_servers` | `[]` | no | Optional fallback NTP servers written to `FallbackNTP=` |

## Usage

The `base` role includes `base_ntp` through meta dependencies.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - base_ntp
```

Example variables:

```yaml
base_ntp_servers:
  - time.cloudflare.com
  - time.google.com
base_ntp_fallback_servers:
  - 0.pool.ntp.org
  - 1.pool.ntp.org
```

## Dependencies
None

## License
MIT

## Author
Tatbyte
