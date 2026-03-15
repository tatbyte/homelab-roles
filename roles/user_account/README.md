# roles/user_account/README.md

Reference for the `user_account` role.
Explains how the role creates and validates one human admin account after the base phase on Debian-family hosts in this repository.

## Features
- Ensures the primary group exists for the human admin account when enabled
- Ensures the human admin user exists with the expected UID, GID, home directory, optional baseline login shell, and basic account settings
- Supports enforcing an existing human admin account instead of assuming fresh creation, while requiring explicit opt-in before moving an existing home directory
- Validates resulting passwd, group, and home-directory state

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `user_account_name` | `admin` | yes | Human admin username to create/manage |
| `user_account_uid` | `1050` | yes when `user_account_state: present` | UID for the human admin account (>= 1000) |
| `user_account_gid` | `1050` | yes when `user_account_state: present` and `user_account_manage_primary_group: true` | GID for the primary group (>= 1000) |
| `user_account_primary_group` | `{{ user_account_name }}` | yes | Primary group name for the human admin account |
| `user_account_state` | `present` | yes | Desired account state: `present` or `absent` |
| `user_account_manage_shell` | `true` | no | If true, manage the account login shell directly; aggregate `user` disables this automatically when `user_zshell` is enabled |
| `user_account_shell` | `/bin/bash` | yes when `user_account_state: present` and `user_account_manage_shell: true` | Baseline login shell for the human admin account when this role owns shell state directly |
| `user_account_home` | `/home/{{ user_account_name }}` | yes when `user_account_state: present` | Home directory for the human admin account |
| `user_account_move_home` | `false` | no | If true, allow the role to move an existing home directory when `user_account_home` differs from the current passwd entry |
| `user_account_manage_primary_group` | `true` | no | If true, ensure the primary group exists before the user is managed |
| `user_account_create_home` | `true` | no | If true, create the home directory for present accounts |
| `user_account_remove` | `false` | no | If true and the account is absent, remove the home directory and mail spool |
| `user_account_comment` | `Human admin account managed by Ansible` | no | Optional GECOS/comment field |

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
Use `user_account_shell` only for the account's baseline login shell when `user_account_manage_shell: true`, and let `user_zshell` manage zsh-specific dotfiles, aliases, environment variables, PATH changes, and the richer login-shell policy.
The aggregate `user` role disables direct shell management in `user_account` automatically when `user_include_zshell: true`.
When adopting an existing user, the role fails early if the current home path differs from `user_account_home` unless `user_account_move_home: true` is set explicitly.
Use `user_password` when you want to manage a hashed local password or password-lock state for the same human admin account.

## Dependencies
None

## Author
tatbyte

## License
MIT
