# roles/base/README.md

Reference for the `base` role.
Explains how the aggregate base role delegates recurring Debian-family host configuration through role dependencies.

## Features
- Runs the recurring base configuration on every `base` execution
- Keeps the always-on base-role orchestration in `roles/base/meta/main.yml`
- Includes `base_packages`, `base_locale`, `base_timezone`, `base_ntp`, `base_hostname`, `base_sudo`, and `base_sshd` through role dependencies
- Can include `base_firewall` as an explicit opt-in follow-up role when `base_include_firewall: true`

## Usage
Use `base` on Debian-family hosts after the bootstrap phase has already created the automation account:

```yaml
- hosts: all
  become: true
  vars:
    base_include_firewall: true
  roles:
    - base
```

Bootstrap is handled separately by the standalone `bootstrap` role/playbook.
Role-specific inputs for `base` currently come from `base_packages_*`, `base_hostname_*`, `base_locale_*`, `base_ntp_*`, `base_sudo_*`, `base_sshd_*`, optional `base_include_firewall` plus `base_firewall_*`, and `base_timezone_*`.

Current dependency order in `base` is:

1. `base_packages`
2. `base_locale`
3. `base_timezone`
4. `base_ntp`
5. `base_hostname`
6. `base_sudo`
7. `base_sshd`

This keeps foundational packages and system environment first, then time synchronization, then final host identity, sudo policy, and SSH daemon policy.

Optional follow-up role:

1. `base_firewall` when `base_include_firewall: true`

Planned future dependency order after the current roles is:

1. `base_logging`
2. `base_updates`
3. `base_apparmor`

## License
MIT

## Author
Tatbyte
