# roles/docker/README.md

Reference for the `docker` role.
Explains how the aggregate Docker role orchestrates Docker-related host setup roles.

## Features

- Runs a stable Docker-layer workflow through explicit `include_role` tasks.
- Uses aggregate toggles (`docker_include_*`) to enable optional child roles.
- Keeps foundational container runtime setup first, then optional Docker service follow-up roles.
- Keeps aggregate include tags aligned with child role tags for predictable targeted runs.

## Usage

Use `docker` after `user` so both the automation account and the managed human
admin account already exist before Docker supplementary-group access is
applied:

```yaml
- hosts: all
  become: true
  roles:
    - role: base
    - role: user
    - role: docker
```

Enable optional child roles with aggregate toggles:

```yaml
docker_include_<role>: true
```

Keep child-role inputs in matching role-scoped vars using `<role>_*`.

## Ordering and Source Of Truth

- Current include order is defined in `roles/docker/tasks/main.yml`.
- Keep this README general; update `tasks/main.yml` when adding or reordering child roles.

## Tag Behavior

Aggregate include tasks should expose:

- generic phase tags (`assert`, `install`, `config`, `validate`)
- aggregate tag (`docker`)
- child-role tags (`<child_role>`, `<child_role>_validate`, etc.)

This keeps both broad and narrow tagged runs predictable.

## Dependencies
None

## License
MIT

## Author
Tatbyte
