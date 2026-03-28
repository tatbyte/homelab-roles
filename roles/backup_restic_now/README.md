# roles/backup_restic_now/README.md

Reference for the `backup_restic_now` role.
Explains how this validation-oriented companion role forces the managed
`backup-restic.service` oneshot unit to run immediately and then inspects the
JSON status output.

## Purpose
- Reuse the already managed recurring backup service instead of duplicating backup logic
- Trigger an immediate backup run for testing or operator-driven validation
- Read and assert the machine-readable JSON result written by `backup_restic`

## Notes
- Apply `backup_restic` first. This role expects the managed service unit and script to already exist.
- This role is reusable, but intentionally opt-in. It is meant for explicit operational runs, not automatic steady-state execution.
- The default allowed statuses are `ok` and `warn`, so harmless warnings can still pass a manual validation run.

## Usage

```yaml
- name: Run backup now for validation
  hosts: backup
  become: true
  roles:
    - role: backup_restic_now
```

## Dependencies
None

## License
MIT
