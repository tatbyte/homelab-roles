# roles/base/README.md

Reference for the `base` role.
Explains how the aggregate base role orchestrates recurring Debian-family host baseline roles.

## Features

- Runs a stable base-phase workflow through explicit `include_role` tasks.
- Keeps required baseline components first, then optional follow-up components.
- Uses aggregate toggles (`base_include_*`) to enable optional child roles.
- Keeps aggregate include tags aligned with child role tags for predictable targeted runs.

## Usage

Use `base` after bootstrap has created the automation account:

```yaml
- hosts: all
  become: true
  roles:
    - role: base
```

To enable optional child roles, set aggregate toggles in aggregate-scoped vars:

```yaml
base_include_<role>: true
```

Keep child-role inputs in matching role-scoped vars using `<role>_*`.

## Ordering and Source Of Truth

- Current include order is defined in `roles/base/tasks/main.yml`.
- Keep this README general; update `tasks/main.yml` when adding or reordering child roles.
- Preserve the broad shape: foundation first, then identity/access baseline, then optional hardening and maintenance follow-up roles.

## Tag Behavior

Aggregate include tasks should expose:

- generic phase tags (`assert`, `install`, `config`, `validate`)
- aggregate tag (`base`)
- child-role tags (`<child_role>`, `<child_role>_validate`, etc.)

This keeps both broad and narrow tagged runs predictable.

## License
MIT

## Author
Tatbyte
