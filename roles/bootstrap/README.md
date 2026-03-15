# roles/bootstrap/README.md

Reference for the `bootstrap` role.
Explains how the role creates and validates the automation account used after the bootstrap phase on Debian-family hosts in this repository.

## Features
- Ensures primary group exists for the automation account
- Ensures automation user exists with expected UID/GID/shell and sudo-group membership
- Optionally installs passwordless sudo for the automation account
- Optionally installs an SSH public key
- Validates resulting passwd/group/key state

## Variables

| Variable                     | Default     | Required | Description                                 |
|-----------------------------|-------------|----------|---------------------------------------------|
| `bootstrap_user`            | `admin`     | yes      | Automation username to create/manage        |
| `bootstrap_puid`            | `1100`      | yes      | UID for automation user (>= 1000)           |
| `bootstrap_pgid`            | `1100`      | yes      | GID for automation user (>= 1000)           |
| `bootstrap_sudo_group`      | `sudo`      | yes      | Sudo-capable group that must include user   |
| `bootstrap_passwordless_sudo` | `false`   | no       | If true, write `/etc/sudoers.d/90-<user>` with `NOPASSWD` |
| `bootstrap_user_shell`      | `/bin/bash` | yes      | Shell for automation user (absolute path)   |
| `bootstrap_authorized_key`  | `""`        | no       | SSH public key to add to automation user    |

## Usage

Direct usage:

```yaml
- hosts: bootstrap
  become: true
  roles:
    - bootstrap
```

Example combined flow in this repo:

```yaml
- hosts: bootstrap
  become: true
  roles:
    - bootstrap

- hosts: all
  become: true
  roles:
    - base
```

Connection credentials for the initial bootstrap login are usually provided in inventory (for example `[bootstrap:vars]`).

## Dependencies
None

## Author
tatbyte

## License
MIT
