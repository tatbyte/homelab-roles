# roles/backup_restic_check/README.md

Reference for the `backup_restic_check` role.
Explains how this recurring companion role verifies repository health through a
dedicated systemd timer and writes its own JSON status file.

## Purpose
- Run `restic check` on a separate recurring schedule
- Keep repository verification independent from the normal backup timer
- Write `/var/lib/monitor/restic-check.json` so monitoring can track check
  health separately from snapshot creation

## Notes
- The role has its own service, timer, script, environment file, and status
  JSON path.
- By default it inherits repository credentials and backend environment from
  `backup_restic`, but it does not pause host containers because check is
  repository-only work.
- The default check mode is metadata-only. Set
  `backup_restic_check_read_data_subset` when you want periodic data reads
  too, for example `10%` or `100%`.

## Usage

```yaml
- name: Apply recurring Restic repository check
  hosts: backup
  become: true
  roles:
    - role: backup_restic_check
```

## Dependencies
None

## License
MIT
