# roles/user_profile/README.md

Reference for the `user_profile` role.
Explains how the role manages login and session profile files for one or more
human admin users after the base phase on Debian-family hosts in this
repository.

## Features
- Validates a clear per-user login/profile inventory structure before making changes
- Requires target human admin accounts and home directories to already exist, typically from `user_account`
- Manages one `.profile` file per selected human admin user
- Optionally manages one `.bash_profile` file per selected human admin user
- Supports inventory-driven environment variables, PATH additions, and literal profile lines
- Validates the resulting managed profile-file state after configuration

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `user_profile_default_profile_mode` | `"0644"` | no | Default mode applied to managed `.profile` files when an entry does not override `profile_mode` |
| `user_profile_default_bash_profile_mode` | `"0644"` | no | Default mode applied to managed `.bash_profile` files when an entry does not override `bash_profile_mode` |
| `user_profile_default_environment` | `{}` | no | Reusable default environment-variable mapping exported from managed profile files |
| `user_profile_default_path_additions` | `[]` | no | Reusable default absolute PATH entries prepended in order when the directories exist |
| `user_profile_default_profile_lines` | `[]` | no | Reusable default literal shell lines appended to managed `.profile` files |
| `user_profile_default_bash_profile_sources_profile` | `true` | no | Whether managed `.bash_profile` files should source `.profile` by default |
| `user_profile_default_bash_profile_lines` | `[]` | no | Reusable default literal shell lines appended to managed `.bash_profile` files |
| `user_profile_users` | one entry derived from `user_account_*` plus the default profile inputs | no | Per-user login/profile policies managed by the role |

Each item in `user_profile_users` supports:

| Key | Default | Required | Description |
|-----|---------|----------|-------------|
| `user` | none | yes | Existing human admin username that will own the managed profile files |
| `group` | none | yes | Existing group that will own the managed profile files |
| `home` | none | yes | Existing absolute home-directory path where profile files are written |
| `environment` | `user_profile_default_environment` | no | Mapping of environment variable names to string values exported from managed profile files |
| `path_additions` | `user_profile_default_path_additions` | no | Ordered list of absolute PATH entries prepended when the directories exist |
| `profile_lines` | `user_profile_default_profile_lines` | no | Literal shell lines appended to the managed `.profile` file |
| `manage_bash_profile` | `false` | no | Whether the role should also manage `.bash_profile` for the selected user |
| `bash_profile_sources_profile` | `user_profile_default_bash_profile_sources_profile` | no | Whether the managed `.bash_profile` should source `.profile` before any extra bash-profile lines |
| `bash_profile_lines` | `user_profile_default_bash_profile_lines` | no | Literal shell lines appended to the managed `.bash_profile` file |
| `profile_mode` | `user_profile_default_profile_mode` | no | File mode enforced on the managed `.profile` file |
| `bash_profile_mode` | `user_profile_default_bash_profile_mode` | no | File mode enforced on the managed `.bash_profile` file when it is managed |

## Usage

Use `user_profile` after `user_account` or another earlier account-creation
step has already ensured the target users and home directories exist:

```yaml
- hosts: all
  become: true
  roles:
    - role: user_account
    - role: user_profile
      vars:
        user_profile_users:
          - user: alice
            group: alice
            home: /home/alice
            environment:
              EDITOR: vim
              VISUAL: vim
            path_additions:
              - /home/alice/.local/bin
            profile_lines:
              - umask 022
            manage_bash_profile: true
```

Example aggregate-role usage:

```yaml
- hosts: all
  become: true
  vars:
    user_include_profile: true
  roles:
    - role: user
```

`user_profile` is the right boundary for login/session defaults that should stay
separate from interactive shell-rc behavior.
In this repository, the older `user_shell` issue wording maps to `user_zshell`,
so the aggregate `user` role includes `user_profile` immediately after the
optional `user_zshell` role.
Keep prompt, completion, aliases, and other interactive shell behavior in
`user_zshell`, and keep shared login/session exports, PATH bootstrap, and
optional `.bash_profile` handling here.
When `user_zshell` is enabled, the managed `.zshrc` sources `.profile` when it
exists, so shared `user_profile` exports and PATH bootstrap apply to the main
interactive zsh sessions in this repository too.
The role manages human-admin profile files only and does not create accounts,
manage Git config, or install shell packages.

## Dependencies
None

## Author
tatbyte

## License
MIT
