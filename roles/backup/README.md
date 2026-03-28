# roles/backup/README.md

Reference for the `backup` role.
Explains how the aggregate backup role orchestrates recurring Restic backup,
repository initialization, retention/prune, and repository checks.

## Features

- Runs the recurring backup layer through explicit `include_role` tasks.
- Applies `backup_restic` first so the package, script, environment, and timer
  baseline are present.
- Applies `backup_restic_init` in the same backup flow so missing repositories
  are initialized automatically during normal backup convergence.
- Optionally applies `backup_restic_prune` and `backup_restic_check`, each
  with their own timer, script, and JSON status output.
- Keeps `backup_restic_now` separate as an explicit validation-only role.

## Usage

Use `backup` on hosts that should receive the recurring backup layer:

```yaml
- hosts: backup
  become: true
  roles:
    - role: backup
```

Enable the recurring backup layer with the aggregate toggle:

```yaml
backup_include_restic: true
```

Keep `backup_restic_*` inputs in matching role-scoped vars under
`group_vars/backup/`.

## Ordering And Source Of Truth

- Current include order is defined in `roles/backup/tasks/main.yml`.
- Keep this README general; update `tasks/main.yml` when the backup layer grows.
- The current steady-state flow is `backup_restic`, then `backup_restic_init`,
  then optional `backup_restic_prune`, then optional `backup_restic_check`.

## Tag Behavior

Aggregate include tasks should expose:

- generic phase tags (`assert`, `install`, `config`, `validate`)
- aggregate tag (`backup`)
- child-role tags (`backup_restic`, `backup_restic_init`,
  `backup_restic_prune`, `backup_restic_check`)

This keeps both broad and narrow tagged runs predictable.

## License
MIT

## Author
Tatbyte
