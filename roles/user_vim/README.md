# roles/user_vim/README.md

Reference for the `user_vim` role.
Explains how the role manages `.vimrc` files for one or more human admin users
after the base phase on Debian-family hosts in this repository.

## Features
- Validates a clear per-user `.vimrc` policy before making changes
- Requires target human admin accounts and home directories to already exist, typically from `user_account`
- Manages one `.vimrc` file per selected human admin user
- Supports configurable line-based `.vimrc` content and optional template overrides
- Optionally installs Vim before configuration and validation
- Verifies resulting `.vimrc` ownership, mode, and rendered content after configuration

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `user_vim_install_package` | `true` | no | Whether the role should ensure the Vim package is present before validation and config |
| `user_vim_package_name` | `vim` | no | Debian-family package name installed when `user_vim_install_package: true` |
| `user_vim_binary_name` | `vim` | no | Binary name checked when `user_vim_install_package: false` |
| `user_vim_vimrc_template_name` | `user_vim_vimrc.j2` | no | Default template used for `.vimrc` rendering |
| `user_vim_default_vimrc_mode` | `"0644"` | no | Default mode applied to managed `.vimrc` files |
| `user_vim_default_vimrc_lines` | curated baseline lines | no | Reusable default literal `.vimrc` lines merged into each user policy |
| `user_vim_users` | one entry derived from `user_account_*` | no | Per-user Vim policies managed by the role |

Each item in `user_vim_users` supports:

| Key | Default | Required | Description |
|-----|---------|----------|-------------|
| `user` | none | yes | Existing human admin username that will own the managed `.vimrc` |
| `group` | none | yes | Existing group that will own the managed `.vimrc` |
| `home` | none | yes | Existing absolute home directory path where `.vimrc` is written |
| `vimrc_lines` | `[]` | no | Literal `.vimrc` lines appended after the shared defaults for each entry |
| `mode` | `user_vim_default_vimrc_mode` | no | File mode enforced on the managed `.vimrc` |
| `vimrc_template_name` | `user_vim_vimrc.j2` | no | Optional override template filename in `roles/user_vim/templates/`; empty means role default |

## Usage

Use `user_vim` after `user_account` or another earlier account-creation step has already
ensured the target users and home directories exist:

```yaml
- hosts: all
  become: true
  roles:
    - role: user_account
    - role: user_vim
      vars:
        user_vim_users:
          - user: alice
            group: alice
            home: /home/alice
            vimrc_lines:
              - set number
              - set expandtab
              - set shiftwidth=4
              - set tabstop=4
```

Example aggregate-role usage:

```yaml
- hosts: all
  become: true
  vars:
    user_include_vim: true
  roles:
    - role: user
```

`.vimrc` ownership and rendering are handled per target user through the effective
policy derived by the role. Keep template-specific syntax intentionally inside
the role-owned template files.

## Dependencies
None

## Author
tatbyte

## License
MIT
