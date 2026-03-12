# examples/README.md

Guide for the local example lab in `examples/`.
Explains the example file layout, the explicit bootstrap phase, and the follow-up base phase for Debian-family hosts.

## Scope
This example lab targets Debian-family hosts such as Debian and Ubuntu.
The inventory variables and role inputs assume the repository's Debian-family defaults and filesystem paths.

## Structure
- `ansible.cfg`: Test-specific Ansible configuration that points at the example inventory and hides skipped-host output for quieter local runs.
- `inventory/hosts.ini`: Test inventory.
- `inventory/group_vars/all/`: Shared variables for test hosts, split into per-role files such as `bootstrap.yml`, `base_packages.yml`, `base_hostname.yml`, `base_locale.yml`, `base_ntp.yml`, `base_sudo.yml`, `base_sshd.yml`, `base_firewall.yml`, `base_logging.yml`, `base_updates.yml`, `base_apparmor.yml`, `base_upgrade.yml`, `base_timezone.yml`, and `monitoring_authorized_key.yml`.
- `playbooks/bootstrap.yml`: Bootstrap phase playbook that connects with the initial admin account and applies the standalone `bootstrap` role.
- `playbooks/base.yml`: Base phase playbook that connects as the automation account, applies the `base` role, and uses `serial: 1` so reboot-capable base runs process one host at a time.
- `playbooks/site.yml`: Base-phase entry playbook that imports `base.yml`.
- `playbooks/test_base_sshd.yml`: Integration test playbook that temporarily adds extra SSH daemon fragments, runs `base_sshd`, verifies merged `AllowUsers` plus `Match User` and `Match Address` behavior, and removes the temporary fixtures.

## Usage
Run bootstrap from repository root:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/bootstrap.yml
```

Then run the base phase:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/site.yml
```

Or run directly from the `examples/` directory:

```sh
ansible-playbook playbooks/bootstrap.yml
ansible-playbook playbooks/site.yml
```

Equivalent direct base-phase command:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/base.yml
```

Optional `base_sshd` integration check:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/test_base_sshd.yml --tags base_sshd
```

The SSH integration test playbook cleans up its temporary `/etc/ssh/sshd_config.d/` fixture files in an `always` block, so you do not need to remove them manually after the run.
`inventory/group_vars/all/base_firewall.yml` sets `base_include_firewall: true`, which opts the example base run into the optional `base_firewall` role.
`inventory/group_vars/all/base_logging.yml` sets `base_include_logging: true`, which opts the example base run into the optional `base_logging` role with persistent journald storage enabled.
`inventory/group_vars/all/base_updates.yml` sets `base_include_updates: true`, which opts the example base run into the optional `base_updates` role with unattended-upgrades enabled.
`inventory/group_vars/all/base_apparmor.yml` sets `base_include_apparmor: true`, which opts the example base run into the optional `base_apparmor` role with the AppArmor service enabled.
`inventory/group_vars/all/base_upgrade.yml` keeps `base_include_upgrade: false` by default, so the example lab documents the role inputs without making every base run apply immediate package upgrades.
`playbooks/base.yml` uses `serial: 1`, which is safer when optional roles such as `base_upgrade` may reboot a host during the run.
`ansible.cfg` sets `display_skipped_hosts = False`, so optional-role and conditional-task skips are hidden during normal example runs.

## Bootstrap Credentials
The example inventory stores only the bootstrap login user:

- `bootstrap_login_user`

`playbooks/bootstrap.yml` prompts once for the bootstrap password and reuses it for both SSH login and sudo.

## Extending
- Add playbooks under `examples/playbooks/`.
- Update `examples/inventory/hosts.ini` and the role-scoped files under `examples/inventory/group_vars/all/` as needed.
- Keep this README aligned with any new test scenarios.
