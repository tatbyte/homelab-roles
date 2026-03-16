# roles/user_directories/README.md

Reference for the `user_directories` role.
Explains how the role standardizes common home-directory paths for one or more human admin users after the base phase on Debian-family hosts in this repository.

## Features
- Validates a clear per-user directory inventory structure before making changes
- Requires target human admin accounts and home directories to already exist, typically from `user_account`
- Creates common home-directory paths such as `.local/bin`, `scripts`, `.config`, and `projects`
- Enforces owner, group, and mode for each managed directory
- Validates the resulting managed directory state after configuration

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `user_directories_default_directory_mode` | `"0755"` | no | Default mode applied to managed directories when an entry does not override `mode` |
| `user_directories_standard_directories` | `.local/bin`, `scripts`, `.config`, `projects` | no | Reusable standard relative directory definitions used by the default per-user policy |
| `user_directories_users` | one entry derived from `user_account_*` and `user_directories_standard_directories` | no | Per-user directory policies managed by the role |

Each item in `user_directories_users` supports:

| Key | Default | Required | Description |
|-----|---------|----------|-------------|
| `user` | none | yes | Existing human admin username that will own the managed directories |
| `group` | none | yes | Existing group that will own the managed directories |
| `home` | none | yes | Existing absolute home-directory path under which relative directory paths are created |
| `directories` | none | yes | List of relative directory definitions created below `home` |

Each item in `directories` supports:

| Key | Default | Required | Description |
|-----|---------|----------|-------------|
| `path` | none | yes | Relative directory path created below the selected user's `home` path; trailing `/` is normalized away and the home directory itself is not a valid target |
| `mode` | `user_directories_default_directory_mode` | no | File mode enforced on the managed directory |

## Usage

Use `user_directories` after `user_account` or another earlier account-creation step has already ensured the target users and home directories exist:

```yaml
- hosts: all
  become: true
  roles:
    - role: user_account
    - role: user_directories
      vars:
        user_directories_users:
          - user: alice
            group: alice
            home: /home/alice
            directories:
              - path: .local/bin
              - path: scripts
              - path: .config
                mode: "0700"
              - path: projects
```

Example aggregate-role usage:

```yaml
- hosts: all
  become: true
  vars:
    user_include_directories: true
  roles:
    - role: user
```

Keep directory paths relative to the selected user's home so the role stays focused on personal workspace layout rather than arbitrary filesystem management.
The default `.local/bin` path matches the example `user_zshell` PATH convention, so user-level executables and the managed shell profile stay aligned by default.
The aggregate `user` role includes `user_directories` after the optional `user_zshell` role so shell policy can settle first and directory standardization follows the current shell-layer ordering.
The role intentionally manages directories only.
Keep shell RC content, profile files, and arbitrary file deployment in dedicated future roles unless they are directly coupled to directory creation.

## Dependencies
None

## Author
tatbyte

## License
MIT
