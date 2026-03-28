# roles/backup_restic_init/README.md

Reference for the `backup_restic_init` role.
Explains how this operational companion role probes the configured Restic
repository and initializes it once when the backend reports that the
repository does not exist yet.

## Purpose
- Reuse the same repository and credential inputs as `backup_restic`
- Probe the backend first instead of blindly initializing every time
- Give consumer repos and the example lab a clean first-run bootstrap path

## Notes
- This role is reusable, but the aggregate `backup` role is now the normal
  steady-state entrypoint. It applies `backup_restic` first and then runs this
  role so missing repositories are initialized automatically during the normal
  backup-layer path.
- Direct callers should still run `backup_restic` first so the host has the
  expected Restic package and related configuration in place.

## Usage

```yaml
- name: Initialize backup repository if missing
  hosts: backup
  become: true
  roles:
    - role: backup_restic
    - role: backup_restic_init
```

## Dependencies
None

## License
MIT
