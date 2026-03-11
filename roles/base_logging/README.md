# roles/base_logging/README.md

Reference for the `base_logging` role.
Explains how the role manages a persistent local journald baseline on Debian-family hosts during the base phase.

## Features
- Validates the requested journald package, service, storage mode, and core logging limit inputs
- Installs any requested journald-related packages with APT before configuration
- Manages `/var/log/journal` so persistent logging is explicit instead of relying on host-local defaults
- Fully manages `/etc/systemd/journald.conf` through a template
- Ensures the journald service is running and restarts it only when the managed config or storage state changes
- Verifies the managed configuration file, storage directory state, and running journald service after changes

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_logging_packages` | `[]` | no | Optional package list installed with APT before journald configuration |
| `base_logging_service_name` | `systemd-journald` | no | Journald service name managed and validated by the role |
| `base_logging_storage` | `persistent` | no | Journald storage mode managed by the role; supported values are `persistent` and `volatile` |
| `base_logging_compress` | `true` | no | Whether journald should compress larger journal objects |
| `base_logging_system_max_use` | `512M` | no | Upper size limit written to `SystemMaxUse=` in the managed journald configuration |

## Usage

The `base` role can include `base_logging` when `base_include_logging: true`.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - base_logging
```

Example variables:

```yaml
base_include_logging: true
base_logging_storage: persistent
base_logging_system_max_use: 256M
```

Set `base_logging_storage: volatile` when you want to keep journald logs only under `/run/log/journal`; this role removes `/var/log/journal` in that mode so persistent local logs do not linger from an older baseline.

## Dependencies
None

## License
MIT

## Author
Tatbyte
