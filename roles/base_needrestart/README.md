# roles/base_needrestart/README.md

Reference for the `base_needrestart` role.
Explains how the role installs `needrestart` and reports restart follow-up state on Debian-family hosts during the base phase.

## Features
- Validates the requested package list, restart-check mode, and failure-policy inputs
- Installs `needrestart` explicitly with APT
- Runs `needrestart` in non-interactive batch mode during the Ansible run
- Exposes whether service restart or reboot follow-up is currently needed
- Can fail the run when reboot follow-up or service restart follow-up is still pending
- Skips the restart check automatically only when `base_upgrade` already ran in the same play, reported no package-maintenance changes, and did not leave the host in a reboot-required state
- Avoids automatic service restarts in this v1 restart-check-only role

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_needrestart_packages` | `['needrestart']` | no | Package list installed with APT to provide the restart-check command |
| `base_needrestart_mode` | `l` | no | Restart mode passed to `needrestart -r`; this role currently supports `l` only so v1 stays restart-check-only |
| `base_needrestart_fail_if_reboot_required` | `false` | no | Whether the role should fail validation when `needrestart` reports reboot follow-up is required |
| `base_needrestart_fail_if_service_restart_required` | `false` | no | Whether the role should fail validation when `needrestart` reports service restart follow-up is required |

## Usage

The aggregate `base` role reads `base_needrestart_enabled` from the
role-scoped base vars file.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - base_needrestart
```

Example variables:

```yaml
base_needrestart_enabled: true
base_needrestart_mode: l
base_needrestart_fail_if_reboot_required: true
base_needrestart_fail_if_service_restart_required: true
```

Use `base_upgrade` when you want to apply package upgrades during the current run.
Use `base_needrestart` when you want a dedicated, reviewable restart-check pass after package maintenance or at any later point in the base phase.
When both roles are enabled through the aggregate `base` role, `base_needrestart` runs after `base_upgrade` so restart follow-up reflects the latest package-maintenance state.
When the same run's `base_upgrade` role exposes `base_upgrade_changed: false` and also leaves `base_upgrade_reboot_required: false`, this role skips the `needrestart` batch check and exposes an empty no-follow-up state instead of rechecking unchanged package state.
Keep the fail flags set to `false` when you want report-only behavior instead of a strict failure gate.

## Dependencies
None

## License
MIT

## Author
Tatbyte
