# roles/user_git/README.md

Reference for the `user_git` role.
Explains how the role manages Git identity and behavior for one or more human admin users after the base phase on Debian-family hosts in this repository.

## Features
- Validates a clear per-user Git inventory structure before making changes
- Optionally ensures the `git` package is present as a prerequisite before configuration and validation
- Requires target human admin accounts and home directories to already exist, typically from `user_account`
- Manages one `~/.gitconfig` file per selected human admin user
- Supports inventory-driven Git identity, aliases, and simple `section.option` settings
- Validates the resulting managed Git config entries after configuration

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `user_git_install_package` | `true` | no | Whether the role should ensure the Git package is present before validation and config-entry checks |
| `user_git_package_name` | `git` | no | Debian-family package name installed when `user_git_install_package: true` |
| `user_git_default_gitconfig_mode` | `"0644"` | no | Default mode applied to managed `~/.gitconfig` files when an entry does not override `mode` |
| `user_git_default_aliases` | `{}` | no | Reusable default alias mapping merged in by the default per-user policy |
| `user_git_default_settings` | `{}` | no | Reusable default `section.option` setting mapping merged in by the default per-user policy |
| `user_git_users` | one entry derived from `user_account_*` plus the default alias and settings mappings | no | Per-user Git policies managed by the role |

Each item in `user_git_users` supports:

| Key | Default | Required | Description |
|-----|---------|----------|-------------|
| `user` | none | yes | Existing human admin username that will own the managed `.gitconfig` file |
| `group` | none | yes | Existing group that will own the managed `.gitconfig` file |
| `home` | none | yes | Existing absolute home-directory path where `.gitconfig` is written |
| `name` | none | yes | Git identity name written under `[user]` |
| `email` | none | yes | Git identity email written under `[user]` |
| `aliases` | `user_git_default_aliases` | no | Mapping of alias names to Git commands written under `[alias]` |
| `settings` | `user_git_default_settings` | no | Mapping of `section.option` keys to string values written into additional Git config sections |
| `mode` | `user_git_default_gitconfig_mode` | no | File mode enforced on the managed `.gitconfig` file |

## Usage

Use `user_git` after `user_account` or another earlier account-creation step has already ensured the target users and home directories exist:

```yaml
- hosts: all
  become: true
  roles:
    - role: user_account
    - role: user_git
      vars:
        user_git_users:
          - user: alice
            group: alice
            home: /home/alice
            name: Alice Example
            email: alice@example.invalid
            aliases:
              st: status --short --branch
              lg: log --oneline --graph --decorate
            settings:
              init.defaultBranch: main
              pull.rebase: "false"
              user.signingkey: ABCDEF0123456789
              commit.gpgsign: "true"
```

Example aggregate-role usage:

```yaml
- hosts: all
  become: true
  vars:
    user_include_git: true
  roles:
    - role: user
```

Keep `settings` keys in `section.option` form so the role can render deterministic Git sections cleanly.
The role reserves `user.name`, `user.email`, and `alias.*` for the dedicated identity and alias inputs.
Simple signing configuration is supported through `settings` values such as `user.signingkey`, `commit.gpgsign`, `tag.gpgSign`, or `gpg.format`.
When `user_git_install_package: false`, Git must already be available on the host because validation reads back the resulting config entries through the `git config --file` interface.
The aggregate `user` role includes `user_git` after the optional `user_directories` role so the home-directory layout settles before Git config is written.

## Dependencies
None

## Author
tatbyte

## License
MIT
