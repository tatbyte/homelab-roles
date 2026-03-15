# examples/README.md

Guide for the local example lab in `examples/`.
Explains the example file layout, the explicit bootstrap phase, and the follow-up base plus user phases for Debian-family hosts.

## Scope
This example lab targets Debian-family hosts such as Debian and Ubuntu.
The inventory variables and role inputs assume the repository's Debian-family defaults and filesystem paths.

## Structure
- `ansible.cfg`: Test-specific Ansible configuration that points at the example inventory and hides skipped-host output for quieter local runs.
- `inventory/hosts.ini`: Test inventory.
- `inventory/group_vars/all/`: Shared variables for test hosts, split into aggregate-scoped files such as `base.yml` and `user.yml`, plus role-scoped files such as `bootstrap.yml`, `base_packages.yml`, `base_hostname.yml`, `base_hosts.yml`, `base_dns.yml`, `base_locale.yml`, `base_ntp.yml`, `base_sudo.yml`, `base_sshd.yml`, `base_firewall.yml`, `base_fail2ban.yml`, `base_logging.yml`, `base_updates.yml`, `base_apparmor.yml`, `base_auditd.yml`, `base_upgrade.yml`, `base_needrestart.yml`, `base_timezone.yml`, `user_account.yml`, `user_groups.yml`, `user_sudo.yml`, `user_password.yml`, and `monitoring_authorized_key.yml`.
- `playbooks/bootstrap.yml`: Bootstrap phase playbook that connects with the initial admin account and applies the standalone `bootstrap` role.
- `playbooks/base.yml`: Base phase playbook that connects as the automation account, applies the `base` role, and uses `serial: 1` so reboot-capable base runs process one host at a time.
- `playbooks/user.yml`: User phase playbook that connects as the automation account after the base phase and applies the aggregate `user` role.
- `playbooks/site.yml`: Post-bootstrap entry playbook that imports `base.yml` and then `user.yml`.
- `playbooks/tests/test_base_sshd.yml`: Integration test playbook that temporarily adds extra SSH daemon fragments, runs `base_sshd`, verifies merged `AllowUsers` plus `Match User` and `Match Address` behavior, and removes the temporary fixtures.

## Usage
Run bootstrap from repository root:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/bootstrap.yml
```

Then run the full post-bootstrap stack:

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

Equivalent direct user-phase command:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/user.yml
```

Optional `base_sshd` integration check:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/tests/test_base_sshd.yml --tags base_sshd
```

The SSH integration test playbook cleans up its temporary `/etc/ssh/sshd_config.d/` fixture files in an `always` block, so you do not need to remove them manually after the run.
`inventory/group_vars/all/base.yml` keeps the aggregate `base_include_*` toggles in one place so enabled optional base roles are easy to scan.
`inventory/group_vars/all/base_firewall.yml` documents the shared firewall baseline, the role-declared rule accumulator, and the `managed:` comment convention used for stale-rule cleanup when `base.yml` enables `base_firewall`.
`inventory/group_vars/all/base_logging.yml` defines the persistent journald baseline used when `base.yml` enables `base_logging`.
`inventory/group_vars/all/base_updates.yml` defines the unattended-upgrades baseline used when `base.yml` enables `base_updates`.
`inventory/group_vars/all/base_apparmor.yml` defines the AppArmor service baseline used when `base.yml` enables `base_apparmor`.
`inventory/group_vars/all/base_auditd.yml` defines the audit-daemon baseline used when `base.yml` enables `base_auditd`.
`inventory/group_vars/all/base_fail2ban.yml` defines the managed SSH jail baseline used when `base.yml` enables `base_fail2ban`.
`inventory/group_vars/all/base_hosts.yml` defines the inventory-driven hosts-file baseline used when `base.yml` enables `base_hosts`.
`inventory/group_vars/all/base_dns.yml` defines the explicit `systemd-resolved` baseline used when `base.yml` enables `base_dns`.
`inventory/group_vars/all/base_upgrade.yml` defines the immediate package-maintenance behavior used when `base.yml` enables `base_upgrade`.
`inventory/group_vars/all/base_needrestart.yml` defines the restart-check behavior used when `base.yml` enables `base_needrestart`.
This means the example base run may fail intentionally after package maintenance when restart follow-up is still pending; set the `base_needrestart_fail_if_*` values back to `false` for report-only example runs.
When the example run's `base_upgrade` role makes no package-maintenance changes and leaves no reboot-required follow-up, `base_needrestart` now skips the batch check automatically to reduce no-change noise.
`playbooks/base.yml` uses `serial: 1`, which is safer when optional roles such as `base_upgrade` may reboot a host during the run.
`inventory/group_vars/all/user_account.yml` defines the example human admin account enforced after the base phase through the aggregate `user` role.
`inventory/group_vars/all/user_groups.yml` defines the example supplementary admin-group baseline, the future role-declared accumulator, and the inventory-specific follow-up layer used when `user.yml` enables `user_groups`.
`inventory/group_vars/all/user_sudo.yml` defines the explicit sudoers drop-in enforced for the example human admin account when `user.yml` enables `user_sudo`.
`inventory/group_vars/all/user.yml` enables the optional supplementary-group, sudo, and password roles in the example lab, while `inventory/group_vars/all/user_password.yml` sets a demo SHA-512 password hash for the example human admin account using the plaintext test password `password` and documents that a real host should use a Vault-managed hash instead.
`ansible.cfg` sets `display_skipped_hosts = False`, so optional-role and conditional-task skips are hidden during normal example runs.

## Bootstrap Credentials
The example inventory stores only the bootstrap login user:

- `bootstrap_login_user`

`playbooks/bootstrap.yml` prompts once for the bootstrap password and reuses it for both SSH login and sudo.

## Extending
- Add playbooks under `examples/playbooks/`.
- Update `examples/inventory/hosts.ini` and the aggregate-scoped plus role-scoped files under `examples/inventory/group_vars/all/` as needed.
- Keep this README aligned with any new test scenarios.
