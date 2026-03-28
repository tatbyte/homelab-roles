# roles/base_upgrade/README.md

Reference for the `base_upgrade` role.
Explains how the role applies explicit APT package upgrades on Debian-family hosts during the base phase.

## Features
- Validates the requested APT cache, upgrade mode, autoremove, and reboot-handling inputs
- Refreshes APT package metadata before applying upgrades
- Applies either a safe upgrade or a full upgrade explicitly during the run
- Optionally removes unused packages after the upgrade
- Detects whether the host requires reboot after package maintenance
- Exposes whether package upgrades, autoremove, or overall package maintenance changed the host during the run
- Can reboot automatically only when explicitly enabled
- Verifies the requested upgrade convergence and resulting reboot-required state after changes

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_upgrade_cache_valid_time` | `0` | no | APT cache age in seconds before the role refreshes package metadata; `0` forces a refresh on every role run |
| `base_upgrade_mode` | `safe` | no | Upgrade mode applied during the run; supported values are `safe` and `full` |
| `base_upgrade_autoremove` | `false` | no | Whether the role should remove unused dependency packages after the requested upgrade |
| `base_upgrade_allow_reboot` | `false` | no | Whether the role may reboot the host automatically when package maintenance requires it |
| `base_upgrade_fail_if_reboot_required` | `false` | no | Whether the role should fail validation when the host still requires reboot after package maintenance |

## Usage

The aggregate `base` role reads `base_upgrade_enabled` from the role-scoped
base vars file.

Direct usage:

```yaml
- hosts: all
  serial: 1
  become: true
  roles:
    - base_upgrade
```

Example variables:

```yaml
base_upgrade_enabled: true
base_upgrade_mode: safe
base_upgrade_autoremove: false
base_upgrade_allow_reboot: false
base_upgrade_fail_if_reboot_required: false
```

Use `base_updates` when you want to manage unattended-upgrades policy for future automatic maintenance.
Use `base_upgrade` when you want a reviewable, immediate upgrade action during the current Ansible run.
When `base_upgrade_allow_reboot: true`, prefer running the play with `serial: 1` so only one host upgrades and reboots at a time.
This role also exposes `base_upgrade_upgrade_changed`, `base_upgrade_autoremove_changed`, and `base_upgrade_changed` for downstream roles such as `base_needrestart`.

## Dependencies
None

## License
MIT

## Author
Tatbyte
