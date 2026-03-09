# roles/base_sudo/README.md

Reference for the `base_sudo` role.
Explains how the role enforces recurring sudo policy for the managed automation user on Debian-family hosts during the base phase.

## Features
- Installs the sudo package with APT before policy configuration
- Validates the requested sudo package, user, and group inputs
- Requires the managed user to already exist before sudo policy changes are applied
- Ensures the managed user is a member of the configured sudo group
- Manages `/etc/sudoers.d/90-<user>` for passwordless sudo
- Verifies group membership and managed sudoers drop-in state after changes

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_sudo_packages` | `['sudo']` | no | Package list installed with APT to provide sudo |
| `base_sudo_user` | `ansible` | no | Existing user that must remain in the configured sudo group |
| `base_sudo_group` | `sudo` | no | Sudo-capable group enforced by the role |

## Usage

The `base` role includes `base_sudo` through meta dependencies.
Use it after bootstrap or another account-creation step has already created `base_sudo_user`.
The role always enforces passwordless sudo for the managed user so Ansible base-phase runs keep working without a separate become password flow.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - base_sudo
```

Example variables:

```yaml
base_sudo_user: ansible
base_sudo_group: sudo
```

## Dependencies
None

## License
MIT

## Author
Tatbyte
