# roles/base_apparmor/README.md

Reference for the `base_apparmor` role.
Explains how the role manages a minimal AppArmor baseline on Debian-family hosts during the base phase.

## Features
- Validates the requested AppArmor package, service, and enabled-state inputs
- Installs the requested AppArmor package baseline with APT before service configuration
- Ensures the AppArmor service is enabled and triggers the profile-load path when requested
- Verifies the requested package state, service enabled state, parser path, and active AppArmor kernel interface after changes
- Keeps scope intentionally narrow by not authoring custom profiles or changing per-profile enforcement modes

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_apparmor_packages` | `['apparmor', 'apparmor-utils']` | no | Package list installed with APT to provide the AppArmor userspace baseline and status tooling |
| `base_apparmor_service_name` | `apparmor` | no | AppArmor service name managed and validated by the role |
| `base_apparmor_enabled` | `true` | no | Whether the role should keep the AppArmor service enabled and trigger profile loading during the base phase |

## Usage

The aggregate `base` role reads `base_apparmor_enabled` from the role-scoped
base vars file.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - base_apparmor
```

Example variables:

```yaml
base_apparmor_packages:
  - apparmor
  - apparmor-utils
base_apparmor_enabled: true
```

Set `base_apparmor_enabled: false` only when you intentionally want to keep the AppArmor package baseline installed while stopping and disabling the service; this role does not manage kernel boot parameters or per-profile modes in that path.

## Dependencies
None

## License
MIT

## Author
Tatbyte
