# roles/base_updates/README.md

Reference for the `base_updates` role.
Explains how the role manages a minimal unattended-upgrades baseline on Debian-family hosts during the base phase.

## Features
- Installs the unattended-upgrades package baseline with APT before update-policy configuration
- Validates the requested package list and minimal automatic-update policy inputs
- Fully manages `/etc/apt/apt.conf.d/20auto-upgrades`
- Fully manages `/etc/apt/apt.conf.d/50unattended-upgrades`
- Keeps unattended-upgrades allowed origins configured for the current distro release and its security pocket
- Verifies the managed APT policy files and requested package state after changes

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_updates_packages` | `['unattended-upgrades']` | no | Package list installed with APT to provide unattended-upgrades support; must include `unattended-upgrades` when automatic upgrades are enabled |
| `base_updates_auto_update_package_lists` | `true` | no | Whether APT should refresh package lists automatically |
| `base_updates_unattended_upgrade` | `true` | no | Whether unattended-upgrades should run automatically |
| `base_updates_autoclean_interval` | `7` | no | Autoclean interval in days written to the managed APT periodic policy |
| `base_updates_autoremove` | `true` | no | Whether unattended-upgrades should remove unused dependencies automatically |

## Usage

The `base` role can include `base_updates` when `base_include_updates: true`.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - base_updates
```

Example variables:

```yaml
base_include_updates: true
base_updates_packages:
  - unattended-upgrades
base_updates_unattended_upgrade: true
base_updates_autoclean_interval: 3
```

Set `base_updates_unattended_upgrade: false` when you want automatic package-list refreshes without automatic unattended package installation; this role still manages the same APT policy files in that mode for explicit, reviewable state.
Use `base_upgrade` separately when you want the current Ansible run to apply upgrades immediately instead of only managing future automatic-update policy.

## Dependencies
None

## License
MIT

## Author
Tatbyte
