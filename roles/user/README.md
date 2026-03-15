# roles/user/README.md

Reference for the `user` role.
Explains how the aggregate user role delegates recurring human admin account configuration after the base phase through explicit role includes.

## Features
- Runs the recurring human-admin user configuration on every `user` execution
- Keeps the aggregate user-role execution order in `roles/user/tasks/main.yml`
- Includes `user_account` through an explicit `ansible.builtin.include_role` entry
- Can include `user_groups` as an explicit opt-in follow-up role when `user_include_groups: true`
- Can include `user_sudo` as an explicit opt-in follow-up role when `user_include_sudo: true`
- Can run `user_sudo` in cleanup mode when `user_include_sudo: false` and `user_cleanup_disabled_sudo_drop_in: true`
- Can include `user_password` as an explicit opt-in follow-up role when `user_include_password: true`
- Keeps aggregate include-task tags aligned with the child role's phase tags and role-specific tags so targeted runs such as `--tags validate` or `--tags user_account_validate` stay predictable

## Usage
Use `user` on Debian-family hosts after the `base` role has already applied the base host baseline:

```yaml
- hosts: all
  become: true
  roles:
    - role: base
    - role: user
```

Role-specific inputs for `user` currently come from `user_account_*`, plus optional `user_include_groups` and `user_groups_*`, plus optional `user_include_sudo`, `user_cleanup_disabled_sudo_drop_in`, and `user_sudo_*`, plus optional `user_include_password` and `user_password_*`.

Current include order in `user` is:

1. `user_account`
2. `user_groups` when `user_include_groups: true`
3. `user_sudo` when `user_include_sudo: true`
4. `user_password` when `user_include_password: true`

`roles/user/tasks/main.yml` is the single source of truth for this sequence.
This keeps the human-admin account layer explicit and leaves future `user_*` roles room to be added in a stable order.
When `user_include_sudo: false` and `user_cleanup_disabled_sudo_drop_in: true`, the aggregate still includes `user_sudo` in `absent` mode so a previously managed human-admin sudoers drop-in can be removed cleanly.

Aggregate include-task tags in `roles/user/tasks/main.yml` intentionally mirror the child role phase tags and role-specific tags.
This keeps broad phase runs such as `--tags validate` working across the user stack while also allowing narrow runs such as `--tags user_account`, `--tags user_groups`, `--tags user_sudo`, `--tags user_password`, `--tags user_account_validate`, `--tags user_groups_validate`, `--tags user_sudo_validate`, or `--tags user_password_validate` without unrelated role execution.

## Dependencies
None

## License
MIT

## Author
Tatbyte
