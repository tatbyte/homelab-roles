# roles/user_sudo/README.md

Reference for the `user_sudo` role.
Explains how the role manages explicit sudoers policy for one human admin account after the base phase on Debian-family hosts in this repository.

## Features
- Validates that the target human admin account already exists before sudo management starts
- Supports dedicated per-user sudoers rules or group-based sudoers policy for the existing human admin account
- Supports optional passwordless sudo through an explicit inventory variable
- Manages one auditable sudoers drop-in and validates it with `visudo` before install
- Optionally removes conflicting broad `NOPASSWD:ALL` entries for the managed principal from other active `/etc/sudoers.d/` files when prompted sudo is requested
- Supports explicit absent-state cleanup for removing a previously managed sudoers drop-in
- Verifies the resulting managed sudoers content and any required group membership after configuration

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `user_sudo_state` | `present` | no | Whether the managed sudoers drop-in should exist (`present`) or be removed (`absent`) |
| `user_sudo_user` | `{{ user_account_name | default('admin') }}` | yes | Existing human admin username whose sudo access is managed |
| `user_sudo_policy_type` | `user` | no | Whether the managed sudoers rule targets the human admin account directly (`user`) or one sudo-capable group the user belongs to (`group`) |
| `user_sudo_group` | `sudo` | yes when `user_sudo_policy_type: group` | Group name used for the managed sudoers rule in group-policy mode |
| `user_sudo_passwordless` | `false` | no | If true, write `NOPASSWD:ALL`; if false, require the normal sudo password prompt |
| `user_sudo_cleanup_conflicting_nopasswd_all` | `true` | no | When `user_sudo_passwordless: false`, remove conflicting broad `NOPASSWD:ALL` lines for the managed user or group principal from `/etc/sudoers` and other active `/etc/sudoers.d/` files while leaving command-scoped exceptions intact |
| `user_sudo_drop_in_path` | `/etc/sudoers.d/90-user_sudo-<user>` | no | Managed sudoers drop-in path for the human admin sudo policy; must stay a single file directly under `/etc/sudoers.d/` |

## Usage

Use `user_sudo` after `base` has already installed the host sudo baseline through `base_sudo`, and after `user_account` or `user_groups` has already ensured the target human admin account and any required supplementary group memberships exist.
`base_sudo` remains responsible for the automation account and the host-wide sudo package baseline, while `user_sudo` keeps the human-admin sudoers drop-in separate and explicit.
Validation uses `su -s /bin/sh -c "sudo -k -n true"` to verify prompted versus passwordless behavior, so normal runs expect `su` in addition to the `sudo` and `visudo` tooling provided by the base sudo layer.
If you are converging the currently connected SSH login user from passwordless
sudo to prompted sudo, provide a become password (for example with `-K` or
`ansible_become_password`) or connect as another privileged user such as the
bootstrap automation account. Otherwise Ansible would lose `become` partway
through the run.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - role: base_sudo
    - role: user_account
    - role: user_groups
    - role: user_sudo
      vars:
        user_sudo_user: alice
        user_sudo_policy_type: user
        user_sudo_passwordless: true
```

Cleanup usage:

```yaml
- hosts: all
  become: true
  roles:
    - role: user_sudo
      vars:
        user_sudo_state: absent
        user_sudo_user: alice
```

Example aggregate-role usage:

```yaml
- hosts: all
  become: true
  vars:
    user_include_groups: true
    user_include_sudo: true
    user_sudo_policy_type: group
    user_sudo_group: sudo
  roles:
    - role: user
```

When `user_sudo_policy_type: group`, keep the target user's membership in that group managed earlier, typically through `user_groups`.
When `user_sudo_policy_type: user`, the managed sudoers rule stays scoped to the selected human admin account only.
When `user_sudo_passwordless: false`, the role can also remove conflicting broad `NOPASSWD:ALL` lines for the managed principal from `/etc/sudoers` and other active files under `/etc/sudoers.d/`. This cleanup intentionally targets only broad passwordless-all entries and leaves command-scoped `NOPASSWD` exceptions alone.
When `user_sudo_state: absent`, the role removes the managed drop-in and validates that the file is gone without requiring the target user or group to still exist.
Validation checks both the managed drop-in content and the resulting effective sudo behavior, including whether non-interactive sudo succeeds only when `user_sudo_passwordless: true`.

## Dependencies
None

## Author
tatbyte

## License
MIT
