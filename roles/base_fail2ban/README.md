# roles/base_fail2ban/README.md

Reference for the `base_fail2ban` role.
Explains how the role manages a minimal Fail2ban SSH jail baseline on Debian-family hosts during the base phase.

## Features
- Validates the requested Fail2ban package, service, backend, and SSH jail inputs
- Installs the requested Fail2ban package baseline with APT before configuration
- Fully manages `/etc/fail2ban/jail.local` as a minimal SSH-focused baseline
- Ensures the Fail2ban service is enabled and running
- Verifies the requested package state, managed jail configuration file, running service state, and active SSH jail after changes
- Keeps v1 intentionally narrow by managing only one SSH jail without custom actions or multi-service jail matrices

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_fail2ban_packages` | `['fail2ban']` | no | Package list installed with APT to provide the Fail2ban baseline; must include `fail2ban` |
| `base_fail2ban_service_name` | `fail2ban` | no | Fail2ban service name enabled, restarted, and validated by the role |
| `base_fail2ban_backend` | `systemd` | no | Backend written to the managed SSH jail baseline; supported values are `auto`, `polling`, `pyinotify`, and `systemd` |
| `base_fail2ban_bantime` | `10m` | no | Ban duration written to the managed SSH jail baseline; may be a Fail2ban time string such as `10m` or an integer number of seconds |
| `base_fail2ban_findtime` | `10m` | no | Failure counting window written to the managed SSH jail baseline; may be a Fail2ban time string such as `10m` or an integer number of seconds |
| `base_fail2ban_maxretry` | `5` | no | Number of failed SSH attempts allowed before the managed jail bans an address |

## Usage

The `base` role can include `base_fail2ban` when `base_include_fail2ban: true`.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - base_fail2ban
```

Example variables:

```yaml
base_include_fail2ban: true
base_fail2ban_packages:
  - fail2ban
base_fail2ban_backend: systemd
base_fail2ban_bantime: 10m
base_fail2ban_findtime: 10m
base_fail2ban_maxretry: 5
```

This role intentionally manages only one SSH jail in v1.
It does not yet manage custom actions, per-service jail matrices, or non-SSH policy expansion.

## Dependencies
None

## License
MIT

## Author
Tatbyte
