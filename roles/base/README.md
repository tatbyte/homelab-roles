# roles/base/README.md

Reference for the `base` role.
Explains how the aggregate base role delegates recurring Debian-family host configuration through explicit role includes.

## Features
- Runs the recurring base configuration on every `base` execution
- Keeps the aggregate base-role execution order in `roles/base/tasks/main.yml`
- Includes `base_packages`, `base_locale`, `base_timezone`, `base_ntp`, `base_hostname`, `base_sudo`, and `base_sshd` through explicit `ansible.builtin.include_role` entries
- Keeps aggregate include-task tags aligned with each child role's phase tags and role-specific tags so targeted runs such as `--tags validate` or `--tags base_packages_validate` stay predictable
- Can include `base_firewall` as an explicit opt-in follow-up role when `base_include_firewall: true`
- Can include `base_logging` as an explicit opt-in follow-up role when `base_include_logging: true`
- Can include `base_updates` as an explicit opt-in follow-up role when `base_include_updates: true`
- Can include `base_apparmor` as an explicit opt-in follow-up role when `base_include_apparmor: true`
- Can include `base_upgrade` as an explicit opt-in follow-up role when `base_include_upgrade: true`

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
Role-specific inputs for `base` currently come from `base_packages_*`, `base_hostname_*`, `base_locale_*`, `base_ntp_*`, `base_sudo_*`, `base_sshd_*`, `base_timezone_*`, optional `base_include_firewall` plus `base_firewall_*`, optional `base_include_logging` plus `base_logging_*`, optional `base_include_updates` plus `base_updates_*`, optional `base_include_apparmor` plus `base_apparmor_*`, and optional `base_include_upgrade` plus `base_upgrade_*`.

Current include order in `base` is:

1. `base_packages`
2. `base_locale`
3. `base_timezone`
4. `base_ntp`
5. `base_hostname`
6. `base_sudo`
7. `base_sshd`

`roles/base/tasks/main.yml` is the single source of truth for this sequence.
This keeps foundational packages and system environment first, then time synchronization, then final host identity, sudo policy, and SSH daemon policy.

Aggregate include-task tags in `roles/base/tasks/main.yml` intentionally mirror the child role phase tags and role-specific tags.
This keeps broad phase runs such as `--tags validate` working across the full base stack while also allowing narrow runs such as `--tags base_packages` or `--tags base_packages_validate` without noisy unrelated role execution.

Optional follow-up role:

1. `base_firewall` when `base_include_firewall: true`
2. `base_logging` when `base_include_logging: true`
3. `base_updates` when `base_include_updates: true`
4. `base_apparmor` when `base_include_apparmor: true`
5. `base_upgrade` when `base_include_upgrade: true`

## License
MIT

## Author
Tatbyte
