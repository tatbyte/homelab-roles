# roles/user_sudo/README.md

Reference for the `user_sudo` role.
Explains how the role manages explicit sudoers policy for one human admin account after the base phase on Debian-family hosts in this repository.

## Features
- Validates that the target human admin account already exists before sudo management starts
- Supports dedicated per-user sudoers rules or group-based sudoers policy for the existing human admin account
- Supports optional passwordless sudo through an explicit inventory variable
- Manages one auditable sudoers drop-in and validates it with `visudo` before install
- Verifies the resulting managed sudoers content and any required group membership after configuration

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `user_sudo_user` | `{{ user_account_name | default('admin') }}` | yes | Existing human admin username whose sudo access is managed |
| `user_sudo_policy_type` | `user` | no | Whether the managed sudoers rule targets the human admin account directly (`user`) or one sudo-capable group the user belongs to (`group`) |
| `user_sudo_group` | `sudo` | yes when `user_sudo_policy_type: group` | Group name used for the managed sudoers rule in group-policy mode |
| `user_sudo_passwordless` | `false` | no | If true, write `NOPASSWD:ALL`; if false, require the normal sudo password prompt |
| `user_sudo_drop_in_path` | `/etc/sudoers.d/90-user_sudo-<user>` | no | Managed sudoers drop-in path for the human admin sudo policy; must stay a single file directly under `/etc/sudoers.d/` |

## Usage

Use `user_sudo` after `base` has already installed the host sudo baseline through `base_sudo`, and after `user_account` or `user_groups` has already ensured the target human admin account and any required supplementary group memberships exist.
`base_sudo` remains responsible for the automation account and the host-wide sudo package baseline, while `user_sudo` keeps the human-admin sudoers drop-in separate and explicit.

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
Validation checks both the managed drop-in content and the resulting effective sudo behavior, including whether non-interactive sudo succeeds only when `user_sudo_passwordless: true`.

## Dependencies
None

## Author
tatbyte

## License
MIT
