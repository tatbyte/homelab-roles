# roles/user_account/README.md

Reference for the `user_account` role.
Explains how the role creates and validates one human admin account after the base phase on Debian-family hosts in this repository.

## Features
- Ensures the primary group exists for the human admin account when enabled
- Ensures the human admin user exists with the expected UID, GID, baseline login shell, home directory, and basic account settings
- Supports enforcing an existing human admin account instead of assuming fresh creation, while requiring explicit opt-in before moving an existing home directory
- Can optionally manage password-lock state for SSH-oriented admin access
- Validates resulting passwd, group, and home-directory state

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `user_account_name` | `admin` | yes | Human admin username to create/manage |
| `user_account_uid` | `1050` | yes when `user_account_state: present` | UID for the human admin account (>= 1000) |
| `user_account_gid` | `1050` | yes when `user_account_state: present` and `user_account_manage_primary_group: true` | GID for the primary group (>= 1000) |
| `user_account_primary_group` | `{{ user_account_name }}` | yes | Primary group name for the human admin account |
| `user_account_state` | `present` | yes | Desired account state: `present` or `absent` |
| `user_account_shell` | `/bin/bash` | yes when `user_account_state: present` | Baseline login shell for the human admin account until a future `user_shell` role owns shell policy |
| `user_account_home` | `/home/{{ user_account_name }}` | yes when `user_account_state: present` | Home directory for the human admin account |
| `user_account_move_home` | `false` | no | If true, allow the role to move an existing home directory when `user_account_home` differs from the current passwd entry |
| `user_account_manage_primary_group` | `true` | no | If true, ensure the primary group exists before the user is managed |
| `user_account_create_home` | `true` | no | If true, create the home directory for present accounts |
| `user_account_remove` | `false` | no | If true and the account is absent, remove the home directory and mail spool |
| `user_account_comment` | `Human admin account managed by Ansible` | no | Optional GECOS/comment field |
| `user_account_password_lock` | `null` | no | Optional password-lock state: `true` locks, `false` unlocks, `null` leaves password-lock state unmanaged |

## Usage

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - role: user_account
      vars:
        user_account_name: alice
        user_account_uid: 1051
        user_account_gid: 1051
```

Example role ordering with the planned `user_*` layer:

```yaml
- hosts: all
  become: true
  roles:
    - role: base
    - role: user_account
```

`user_account` intentionally keeps shell handling narrow.
Use `user_account_shell` for the account's baseline login shell, and let a future `user_shell` role manage dotfiles, aliases, environment variables, PATH changes, and any richer shell-policy decisions.
When adopting an existing user, the role fails early if the current home path differs from `user_account_home` unless `user_account_move_home: true` is set explicitly.

## Dependencies
None

## Author
tatbyte

## License
MIT
