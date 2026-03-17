# roles/user_ssh/README.md

Reference for the `user_ssh` role.
Explains how the role manages SSH access files for one or more human admin
users after the base phase on Debian-family hosts in this repository.

## Features
- Validates a clear per-user SSH inventory structure before making changes
- Requires target human admin accounts and home directories to already exist, typically from `user_account`
- Manages one `~/.ssh` directory plus one `authorized_keys` file per selected human admin user
- Optionally manages one `~/.ssh/config` file per selected human admin user
- Optionally manages one `~/.ssh/known_hosts` file per selected human admin user
- Enforces ownership and mode baselines for the managed `.ssh` directory and managed files
- Removes stale previously managed optional SSH client files when their management toggles are turned off
- Supports explicit cleanup targets for users removed from `user_ssh_users` so stale managed SSH files can be revoked in a follow-up run
- Validates the resulting managed SSH file state after configuration

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `user_ssh_default_ssh_directory_mode` | `"0700"` | no | Default mode applied to managed `~/.ssh` directories when an entry does not override `ssh_directory_mode` |
| `user_ssh_default_authorized_keys_mode` | `"0600"` | no | Default mode applied to managed `authorized_keys` files when an entry does not override `authorized_keys_mode` |
| `user_ssh_default_config_mode` | `"0600"` | no | Default mode applied to managed `~/.ssh/config` files when an entry does not override `config_mode` |
| `user_ssh_default_known_hosts_mode` | `"0644"` | no | Default mode applied to managed `~/.ssh/known_hosts` files when an entry does not override `known_hosts_mode` |
| `user_ssh_default_authorized_keys` | `[]` | no | Reusable default authorized key entries prepended to each user policy |
| `user_ssh_default_config_lines` | `[]` | no | Reusable default literal SSH client config lines prepended to each managed `~/.ssh/config` file |
| `user_ssh_default_known_hosts_lines` | `[]` | no | Reusable default literal known-host lines prepended to each managed `~/.ssh/known_hosts` file |
| `user_ssh_cleanup_removed_users` | `[]` | no | Explicit removed-user cleanup targets whose previously managed `authorized_keys`, `config`, and `known_hosts` files should be removed when they still contain the `user_ssh` managed marker |
| `user_ssh_users` | one entry derived from `user_account_*` plus the default SSH inputs | no | Per-user SSH access policies managed by the role |

Each item in `user_ssh_users` supports:

| Key | Default | Required | Description |
|-----|---------|----------|-------------|
| `user` | none | yes | Existing human admin username that will own the managed `.ssh` content |
| `group` | none | yes | Existing group that will own the managed `.ssh` content |
| `home` | none | yes | Existing absolute home-directory path where `.ssh` content is written |
| `authorized_keys` | `user_ssh_default_authorized_keys` | no | List of literal OpenSSH authorized key lines written into `authorized_keys`; the effective list must contain at least one entry |
| `manage_config` | `false` | no | Whether the role should also manage `~/.ssh/config` for the selected user |
| `config_lines` | `user_ssh_default_config_lines` | no | Literal SSH client config lines written into the managed `~/.ssh/config` file when enabled |
| `manage_known_hosts` | `false` | no | Whether the role should also manage `~/.ssh/known_hosts` for the selected user |
| `known_hosts_lines` | `user_ssh_default_known_hosts_lines` | no | Literal known-host lines written into the managed `~/.ssh/known_hosts` file when enabled |
| `ssh_directory_mode` | `user_ssh_default_ssh_directory_mode` | no | Directory mode enforced on the managed `~/.ssh` directory |
| `authorized_keys_mode` | `user_ssh_default_authorized_keys_mode` | no | File mode enforced on the managed `authorized_keys` file |
| `config_mode` | `user_ssh_default_config_mode` | no | File mode enforced on the managed `~/.ssh/config` file when it is managed |
| `known_hosts_mode` | `user_ssh_default_known_hosts_mode` | no | File mode enforced on the managed `~/.ssh/known_hosts` file when it is managed |

Each item in `user_ssh_cleanup_removed_users` supports:

| Key | Default | Required | Description |
|-----|---------|----------|-------------|
| `user` | none | yes | Username label used for cleanup logging and validation |
| `home` | none | yes | Absolute home-directory path whose previously managed `~/.ssh/authorized_keys`, `~/.ssh/config`, and `~/.ssh/known_hosts` files should be removed when they still contain the `user_ssh` managed marker |

## Usage

Use `user_ssh` after `user_account` or another earlier account-creation step
has already ensured the target users and home directories exist:

```yaml
- hosts: all
  become: true
  roles:
    - role: user_account
    - role: user_ssh
      vars:
        user_ssh_users:
          - user: alice
            group: alice
            home: /home/alice
            authorized_keys:
              - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleHumanAdminKeyMaterial alice@example.invalid
            manage_config: true
            config_lines:
              - Host git-lab
              - "  HostName git.example.invalid"
              - "  User git"
              - "  IdentityFile ~/.ssh/id_ed25519"
            manage_known_hosts: true
            known_hosts_lines:
              - git.example.invalid ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleKnownHostKeyMaterial
```

Example aggregate-role usage:

```yaml
- hosts: all
  become: true
  vars:
    user_include_ssh: true
  roles:
    - role: user
```

Keep server login access in `authorized_keys`, optional client shortcuts in
`~/.ssh/config`, and optional host-key baselines in `~/.ssh/known_hosts`.
If you later remove a user from `user_ssh_users`, add that user's old
`user` plus `home` path to `user_ssh_cleanup_removed_users` for one follow-up
run so any previously managed `authorized_keys`, `config`, and `known_hosts`
files are removed safely by marker.
The aggregate `user` role includes `user_ssh` after the optional
`user_password` role and before the optional `user_zshell` role so account
auth, SSH access, and shell-environment concerns stay distinct.
If you also restrict SSH daemon access through `base_sshd_allow_users`, keep
that daemon-side allow-list aligned with the usernames managed here.
This role manages human-admin SSH dotfiles only. It does not manage private
keys, SSH agent setup, or the server-side `sshd` daemon policy.

## Dependencies
None

## Author
tatbyte

## License
MIT
