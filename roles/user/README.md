# roles/user/README.md

Reference for the `user` role.
Explains how the aggregate user role delegates recurring human admin account configuration after the base phase through explicit role includes.

## Features
- Runs the recurring human-admin user configuration on every `user` execution
- Keeps the aggregate user-role execution order in `roles/user/tasks/main.yml`
- Includes `user_account` through an explicit `ansible.builtin.include_role` entry
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

Role-specific inputs for `user` currently come from `user_account_*`.

Current include order in `user` is:

1. `user_account`

`roles/user/tasks/main.yml` is the single source of truth for this sequence.
This keeps the human-admin account layer explicit and leaves future `user_*` roles room to be added in a stable order.

Aggregate include-task tags in `roles/user/tasks/main.yml` intentionally mirror the child role phase tags and role-specific tags.
This keeps broad phase runs such as `--tags validate` working across the user stack while also allowing narrow runs such as `--tags user_account` or `--tags user_account_validate` without unrelated role execution.

## Dependencies
None

## License
MIT

## Author
Tatbyte
