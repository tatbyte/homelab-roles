# roles/monitoring_docker_tag/README.md

Reference for the `monitoring_docker_tag` role.
Explains how the role checks the running Docker containers on a host, compares
their pinned tags against the latest registry tags, and writes a
machine-readable contract that `monitoring_collect` and `monitoring_web` can
surface.

## Purpose
- Check running Docker containers for newer image tags without mutating the host
- Classify update candidates as patch, minor, or major style changes
- Ignore newer tags that do not resolve for the current host CPU architecture
- Record whether an update looks safe to apply immediately and whether a backup
  should be reviewed first
- Publish one JSON contract per host for collector and dashboard use

## Managed Files
- `{{ monitoring_docker_tag_script_path }}`: rendered Docker tag monitoring runner
- `/etc/systemd/system/{{ monitoring_docker_tag_service_unit }}`: oneshot monitoring service
- `/etc/systemd/system/{{ monitoring_docker_tag_timer_unit }}`: recurring schedule
- `{{ monitoring_docker_tag_status_path }}`: per-host Docker tag monitoring JSON

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `monitoring_docker_tag_enabled` | `true` | no | Whether the Docker tag monitor should be active on the host |
| `monitoring_docker_tag_packages` | `['python3', 'skopeo']` | no | Packages needed for the registry lookups |
| `monitoring_docker_tag_status_path` | `/var/lib/monitor/docker-tag.json` | no | Output path for the JSON contract |
| `monitoring_docker_tag_track_stopped_containers` | `false` | no | Whether to inspect all containers instead of only currently running ones |
| `monitoring_docker_tag_backup_enabled` | `{{ backup_include_restic | default(false) }}` | no | Whether the host already has recurring backups enabled |
| `monitoring_docker_tag_backup_stop_containers` | `{{ backup_restic_docker_stop_containers | default([]) }}` | no | Container names that are already stopped before backup runs |
| `monitoring_docker_tag_floating_tags` | see defaults | no | Tags treated as floating and skipped for semantic update guidance |
| `monitoring_docker_tag_registry_auth_file` | `/root/.docker/config.json` | no | Docker auth file passed to `skopeo` when it exists |
| `monitoring_docker_tag_timer_on_calendar` | `*-*-* 09:15:00` | no | systemd calendar expression for the recurring timer |

## Notes
- The role reads the live Docker host state, so it covers both shared
  `docker_*` roles and local environment-specific Compose stacks that are
  already running on the same host.
- Update guidance is semantic and intentionally conservative:
  patch-like bumps are marked as okay to update, while minor and major bumps
  are marked for review first.
- Newer tags are advisory only. They stay visible in the dashboard and `_now`
  notification path, but they do not make the host or fleet rollup warn.
- Tag-family matching is intentionally constrained so branch tags such as `v3`
  only compare within the same major branch, LinuxServer `-lsNNN` tags stay in
  that same family, and flavor markers such as `alpine` stay matched with the
  same flavor family.
- Candidate tags are validated with `skopeo inspect` on the monitored host, so
  only tags that resolve for that host platform are considered update targets.
- Backup guidance is heuristic. The role marks containers with writable bind
  mounts or volumes as likely stateful, then combines that with the existing
  backup-role inputs to show whether backup review is recommended before an
  update.
- Private registries work when the service account running the role already has
  a compatible Docker auth file for `skopeo` to reuse.

## Usage

```yaml
- name: Apply Docker tag monitoring
  hosts: monitoring
  become: true
  roles:
    - role: monitoring_docker_tag
```

## Dependencies
None

## License
MIT
