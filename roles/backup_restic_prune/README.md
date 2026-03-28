# roles/backup_restic_prune/README.md

Reference for the `backup_restic_prune` role.
Explains how this recurring companion role applies Restic retention through a
dedicated systemd timer and writes its own JSON status file.

## Purpose
- Run `restic forget --prune` on a separate recurring schedule
- Keep retention cleanup independent from the normal backup timer
- Write `/var/lib/monitor/restic-prune.json` so monitoring can see prune
  health separately from snapshot creation

## Notes
- The role has its own service, timer, script, environment file, and status
  JSON path.
- By default it inherits repository credentials and backend environment from
  `backup_restic`, but it does not pause host containers because prune is
  repository-only work.
- The default retention policy keeps `7` daily, `5` weekly, and `12` monthly
  snapshots.
- Leave `backup_restic_prune_host_filter` empty for the normal per-repo case.
  Set it only when one repository intentionally stores snapshots from multiple
  hosts and prune must stay scoped to one host value.

## Usage

```yaml
- name: Apply recurring Restic prune
  hosts: backup
  become: true
  roles:
    - role: backup_restic_prune
```

## Dependencies
None

## License
MIT
