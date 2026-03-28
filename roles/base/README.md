# roles/base/README.md

Reference for the `base` role.
Explains how the aggregate base role orchestrates recurring Debian-family host baseline roles.

## Features

- Runs a stable base-phase workflow through explicit `include_role` tasks.
- Keeps required baseline components first, then optional follow-up components.
- Uses role-scoped `base_<role>_enabled` values to decide which child roles
  the aggregate base layer should manage.
- Keeps aggregate include tags aligned with child role tags for predictable targeted runs.

## Usage

Use `base` after bootstrap has created the automation account:

```yaml
- hosts: all
  become: true
  roles:
    - role: base
```

To enable or disable child roles, set role-scoped values in the matching
`group_vars/base/<role>.yml` file and override them per host only when needed:

```yaml
base_<role>_enabled: true
```

The aggregate role still accepts legacy `base_include_*` toggles as
compatibility fallbacks, but new inventory changes should use
`base_<role>_enabled`.

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
