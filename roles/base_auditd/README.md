# roles/base_auditd/README.md

Reference for the `base_auditd` role.
Explains how the role manages a minimal Linux audit daemon baseline on Debian-family hosts during the base phase.

## Features
- Validates the requested audit package, service, enabled-state, and minimal configuration inputs
- Installs the requested audit package baseline with APT before configuration
- Manages a small explicit `auditd.conf` baseline focused on local logging plus the requested flush and log-format behavior
- Ensures the audit daemon service is enabled and running when requested
- Verifies the requested package state, managed configuration file, and service enabled/running state after changes
- Keeps scope intentionally narrow by not authoring audit rules, remote forwarding, or compliance-profile-specific policy in v1

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_auditd_packages` | `['auditd']` | no | Package list installed with APT to provide the Linux audit daemon baseline |
| `base_auditd_service_name` | `auditd` | no | Audit daemon service name managed and validated by the role |
| `base_auditd_enabled` | `true` | no | Whether the role should keep the audit daemon enabled and running during the base phase |
| `base_auditd_flush` | `incremental_async` | no | Flush mode written to the managed `auditd.conf` baseline; supported values are `none`, `incremental`, `incremental_async`, `data`, and `sync` |
| `base_auditd_log_format` | `enriched` | no | Audit log format written to the managed `auditd.conf` baseline; supported values are `raw` and `enriched` |

## Usage

The aggregate `base` role reads `base_auditd_enabled` from the role-scoped
base vars file.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - base_auditd
```

Example variables:

```yaml
base_auditd_packages:
  - auditd
base_auditd_enabled: true
base_auditd_flush: incremental_async
base_auditd_log_format: enriched
```

Set `base_auditd_enabled: false` only when you intentionally want to keep the package and managed configuration baseline present while stopping and disabling the audit daemon service.
This role does not manage audit rule files, remote forwarding, or advanced compliance profiles in v1.

## Dependencies
None

## License
MIT

## Author
Tatbyte
