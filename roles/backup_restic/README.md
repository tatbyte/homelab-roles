# roles/backup_restic/README.md

Reference for the `backup_restic` role.
Explains how the role installs Restic, renders the managed backup script and systemd timer, and writes stable JSON status output for monitoring consumers.

## Purpose
- Run recurring Restic backups through a host-local systemd timer
- Keep the backup scope small and rebuild-friendly for Ansible-managed hosts
- Write `/var/lib/monitor/restic-backup.json` on every backup attempt so other roles can consume a stable machine-readable contract

## Managed Files
- `{{ backup_restic_script_path }}`: rendered backup runner
- `{{ backup_restic_environment_file_path }}`: root-only Restic environment file
- `/etc/systemd/system/{{ backup_restic_service_unit }}`: oneshot backup service
- `/etc/systemd/system/{{ backup_restic_timer_unit }}`: recurring schedule
- `{{ backup_restic_status_path }}`: latest backup result JSON, written by the script when the backup runs

## Default Backup Scope
- Included paths: `/srv`, `/home`, `/root`, `/etc/ssh`, `/etc/letsencrypt`, `/etc/wireguard`, `/etc/systemd/system`, `/var/lib`
- Excluded paths: runtime, cache, temporary, and Docker-rebuildable paths such as `/tmp`, `/run`, `/proc`, `/sys`, `/dev`, `/var/cache`, and `overlay2`

Missing configured backup paths are skipped at runtime and recorded in the `warnings` array instead of failing the whole role.

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `backup_restic_repository` | `""` | yes | Restic repository location passed through `RESTIC_REPOSITORY` |
| `backup_restic_password` | `""` | yes | Repository password passed through `RESTIC_PASSWORD` |
| `backup_restic_extra_environment` | `{}` | no | Extra backend-specific environment variables such as IDrive e2 S3-compatible settings |
| `backup_restic_paths` | issue #79 baseline | no | Paths the backup script will include when they exist |
| `backup_restic_excludes` | issue #79 baseline | no | Paths and globs passed as `--exclude` values |
| `backup_restic_tags` | `[]` | no | Optional Restic snapshot tags |
| `backup_restic_extra_args` | `[]` | no | Additional CLI flags appended before the path list |
| `backup_restic_docker_stop_containers` | `[]` | no | Stateful Docker containers to stop before the backup and start again immediately after |
| `backup_restic_timer_on_calendar` | `*-*-* 03:30:00` | no | systemd calendar expression for the timer |
| `backup_restic_enabled` | `true` | no | Whether the role should keep the timer installed and enabled |

## Usage

```yaml
- name: Apply backup role
  hosts: backup
  become: true
  roles:
    - role: backup_restic
```

Example inventory vars:

```yaml
# group_vars/backup/backup_restic.yml
backup_restic_repository: "{{ vault_backup_restic_idrive_e2_repository }}"
backup_restic_password: "{{ vault_backup_restic_password }}"
backup_restic_extra_environment:
  AWS_S3_FORCE_PATH_STYLE: "true"
  AWS_DEFAULT_REGION: "{{ vault_backup_restic_idrive_e2_region }}"
  AWS_ACCESS_KEY_ID: "{{ vault_backup_restic_idrive_e2_access_key_id }}"
  AWS_SECRET_ACCESS_KEY: "{{ vault_backup_restic_idrive_e2_secret_access_key }}"
backup_restic_tags:
  - ansible-managed
  - "{{ alias | default(inventory_hostname) }}"
backup_restic_docker_stop_containers:
  - "{{ docker_adguard_container_name }}"
  - "{{ docker_wireguard_container_name }}"
```

## Notes
- The role does not force an immediate backup run on every Ansible apply; it installs and starts the timer, and the status JSON appears after the first service execution.
- The JSON schema name is `restic_backup_status_v1`, matching the backup-state contract described in issue `#96`.
- `bytes_added` is derived from Restic's `data_added` summary field.
- The current inventory examples use IDrive e2 through its S3-compatible API, while the role itself stays backend-agnostic.
- Prefer listing only stateful containers that benefit from short app-consistent pauses, such as SQLite-heavy apps or control-plane services with writable config under `/srv`. Leave stateless front-end containers like Traefik out unless you have a specific reason to quiesce them.
- The status JSON now includes a `docker_coordination` object with `configured_containers`, `stopped_containers`, `restarted_containers`, `missing_containers`, `not_running_containers`, `failed_stop_containers`, `failed_restart_containers`, and `ok` so overnight checks can confirm the container pause/resume path worked.

## Dependencies
None

## License
MIT
