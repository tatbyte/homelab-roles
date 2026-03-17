# roles/user/README.md

Reference for the `user` role.
Explains how the aggregate user role orchestrates recurring human-admin account and user-environment roles.

## Features

- Runs a stable user-phase workflow through explicit `include_role` tasks.
- Keeps account baseline first, then optional user-environment follow-up roles.
- Uses aggregate toggles (`user_include_*`) to enable optional child roles.
- Supports explicit cleanup behavior for disabled sudo drop-ins.
- Keeps aggregate include tags aligned with child role tags for predictable targeted runs.

## Usage

Use `user` after `base`:

```yaml
- hosts: all
  become: true
  roles:
    - role: base
    - role: user
```

Enable optional child roles with aggregate toggles:

```yaml
user_include_<role>: true
```

Keep child-role inputs in matching role-scoped vars using `<role>_*`.

## Ordering and Source Of Truth

- Current include order is defined in `roles/user/tasks/main.yml`.
- Keep this README general; update `tasks/main.yml` when adding or reordering child roles.
- Preserve the broad shape: account creation/adoption first, then optional access/policy roles, then optional environment and tooling roles.

Special handling:

- When `user_include_sudo: false` and `user_cleanup_disabled_sudo_drop_in: true`, the aggregate still includes `user_sudo` in cleanup mode (`absent`) to remove a previously managed drop-in.
- When `user_include_zshell: true`, `user_account` shell ownership is disabled so `user_zshell` becomes the single shell owner.

## Tag Behavior

Aggregate include tasks should expose:

- generic phase tags (`assert`, `install`, `config`, `validate`)
- aggregate tag (`user`)
- child-role tags (`<child_role>`, `<child_role>_validate`, etc.)

This keeps both broad and narrow tagged runs predictable.

## Dependencies
None

## License
MIT

## Author
Tatbyte
