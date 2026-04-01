# roles/restore_restic/README.md

Reference for the `restore_restic` role.
Explains how the role performs a manual Restic restore run against the same
repository inputs used by `backup_restic`, while allowing either the full
backup scope or one specific path to be restored through an explicit restore
mode.

## Purpose
- Run a manual Restic restore directly from Ansible without changing the
  recurring backup timer workflow
- Reuse the same repository, password, and backend-environment settings as
  `backup_restic` by default
- Keep the default restore path safe by restoring the full backup scope into
  `/backup`
- Allow explicit in-place full restore or single-path repair mode when you
  really want to write back to `/`

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `restore_restic_repository` | `{{ backup_restic_repository }}` fallback | yes | Restic repository location passed through `RESTIC_REPOSITORY` |
| `restore_restic_password` | `{{ backup_restic_password }}` fallback | yes | Repository password passed through `RESTIC_PASSWORD` |
| `restore_restic_extra_environment` | `{{ backup_restic_extra_environment }}` fallback | no | Extra backend-specific environment variables such as S3-compatible credentials |
| `restore_restic_snapshot` | `latest` | no | Snapshot ID or ref passed to `restic restore` |
| `restore_restic_mode` | `sandbox` | no | Restore behavior: `sandbox`, `in_place`, or `repair_path` |
| `restore_restic_sandbox_target_path` | `/backup` | no | Target directory used when `restore_restic_mode: sandbox` |
| `restore_restic_paths` | `{{ backup_restic_paths }}` fallback | no | Default list of snapshot paths to restore when no single-path override is set |
| `restore_restic_only_path` | `""` | no | Required absolute path when `restore_restic_mode: repair_path`; ignored in other modes |
| `restore_restic_restore_overwrite` | `always` | no | Restic overwrite policy (`always`, `if-changed`, `if-newer`, `never`) |
| `restore_restic_restore_delete` | `false` | no | Whether `restic restore --delete` should remove files missing from the selected restore scope |
| `restore_restic_restore_dry_run` | `false` | no | Whether to preview the restore without writing files |
| `restore_restic_extra_args` | `[]` | no | Additional CLI flags appended before the include list |

## Usage

```yaml
- name: Run a manual restore
  hosts: backup
  become: true
  roles:
    - role: restore_restic
```

Example inventory vars:

```yaml
# group_vars/backup/restore_restic.yml
restore_restic_repository: "{{ backup_restic_repository }}"
restore_restic_password: "{{ backup_restic_password }}"
restore_restic_extra_environment: "{{ backup_restic_extra_environment }}"
restore_restic_mode: sandbox
restore_restic_sandbox_target_path: /backup
restore_restic_paths: "{{ backup_restic_paths }}"
restore_restic_only_path: ""
```

## Restore Modes

- `sandbox`: restore the full configured backup scope into `restore_restic_sandbox_target_path`. This is the safe default because it avoids overwriting live files.
- `in_place`: restore the full configured backup scope back onto `/`.
- `repair_path`: restore only `restore_restic_only_path` back onto `/`.

Examples:

```sh
ansible-playbook playbooks/ops/restore_restic.yml
ansible-playbook playbooks/ops/restore_restic.yml -e restore_restic_mode=in_place
ansible-playbook playbooks/ops/restore_restic.yml -e restore_restic_mode=repair_path -e restore_restic_only_path=/srv/wireguard/data
```

## Notes
- The role installs `restic` if it is missing, then runs the restore command immediately; it does not manage a systemd service or timer.
- `sandbox` mode is the default so operators can inspect restored files under `/backup` before deciding whether anything should be copied back onto the live filesystem.
- `in_place` and `repair_path` both restore onto `/`. The upstream Restic docs recommend taking a fresh backup first because an interrupted in-place restore can leave partially restored files.
- `repair_path` uses Restic's native `--include` filtering, so one selected subtree can be repaired without replaying the full host backup.

## Dependencies
None

## License
MIT
