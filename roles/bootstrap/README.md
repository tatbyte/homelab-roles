# roles/bootstrap/README.md

Reference for the `bootstrap` role.
Explains how the role creates and validates the automation account used after
the bootstrap phase, including the immediate SSH handoff needed for follow-up
Ansible runs on Debian-family hosts in this repository.

## Features
- Ensures primary group exists for the automation account
- Ensures automation user exists with expected UID/GID/shell and sudo-group membership
- Optionally installs passwordless sudo for the automation account
- Optionally installs an SSH public key
- Optionally manages a small SSH handoff drop-in so the automation account can log in immediately after bootstrap
- Validates resulting passwd/group/key and SSH handoff state

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
| `bootstrap_manage_sshd_handoff` | `true` | no | If true, manage a bootstrap SSH drop-in so the automation account can connect before the later base phase |
| `bootstrap_sshd_allow_users` | derived `[bootstrap_user, bootstrap_login_user]` list | no | Login allow-list written to the bootstrap SSH handoff drop-in; keep it aligned with later `base_sshd_allow_users` when both roles manage SSH access |

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
If a host already has an `AllowUsers` restriction or otherwise needs an SSH
handoff before the base phase runs, keep `bootstrap_manage_sshd_handoff: true`
and set `bootstrap_sshd_allow_users` to include both the initial bootstrap
login user and the post-bootstrap automation user.
That keeps the first post-bootstrap `base.yml`, `user.yml`, or `docker.yml`
run from failing just because SSH still allows only the original bootstrap
user. In this repository that specifically covers hosts where SSH still starts
with an `AllowUsers <bootstrap_login_user>` policy, which would otherwise block
the newly created automation account even after its SSH key is installed.
When you also use `base_sshd` later, keep `bootstrap_sshd_allow_users` aligned
with `base_sshd_allow_users` so the early bootstrap handoff and the later base
SSH policy do not drift apart.

## Dependencies
None

## Author
tatbyte

## License
MIT
