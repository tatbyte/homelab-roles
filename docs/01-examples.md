# docs/01-examples.md

Reference document for the example lab in `examples/`.
Explains how the example inventory, variables, and playbooks fit together for the bootstrap phase and the follow-up base plus user phases on Debian-family hosts.

## Purpose

The `examples/` directory is an example environment that shows how to wire:

- inventory
- group variables
- playbooks
- `ansible.cfg`

Use it as a reference template for validating roles on your side.
The example content assumes Debian-family targets such as Debian and Ubuntu.

## Example Files

- `examples/ansible.cfg`: Example Ansible configuration for local test runs that also hides skipped-host output for quieter example runs.
- `examples/inventory/hosts.ini`: Example hosts and groups.
- `examples/inventory/group_vars/all/`: Example variables for all hosts, split into aggregate-scoped files such as `base.yml` and `user.yml`, plus role-scoped files such as `bootstrap.yml`, `base_packages.yml`, `base_hostname.yml`, `base_hosts.yml`, `base_dns.yml`, `base_locale.yml`, `base_ntp.yml`, `base_sudo.yml`, `base_sshd.yml`, `base_firewall.yml`, `base_fail2ban.yml`, `base_logging.yml`, `base_updates.yml`, `base_apparmor.yml`, `base_auditd.yml`, `base_upgrade.yml`, `base_needrestart.yml`, `base_timezone.yml`, `user_account.yml`, `user_groups.yml`, `user_sudo.yml`, `user_password.yml`, and `monitoring_authorized_key.yml`.
- `examples/playbooks/bootstrap.yml`: Bootstrap phase playbook that uses initial host credentials and applies the standalone `bootstrap` role.
- `examples/playbooks/base.yml`: Base phase playbook for post-bootstrap role execution that applies the aggregate base role one host at a time for safer reboot-capable runs.
- `examples/playbooks/user.yml`: User phase playbook for post-base role execution that applies the aggregate `user` role for human admin account enforcement.
- `examples/playbooks/site.yml`: Post-bootstrap entry playbook that imports `base.yml` and then `user.yml`.
- `examples/playbooks/tests/test_base_sshd.yml`: Optional integration test playbook for exercising merged `sshd_config.d` fragments plus `Match User` and `Match Address` behavior around the `base_sshd` role.

## How to Use the Example

1. Copy or adapt the files in `examples/` to your own lab.
2. Replace inventory hosts and credentials with your environment values.
3. Update the aggregate-scoped and role-scoped files in `group_vars/all/` for your role inputs.
4. Run bootstrap first:

```bash
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/bootstrap.yml
```

5. Then run the full post-bootstrap stack:

```bash
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/site.yml
```

Equivalent direct base-phase command:

```bash
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/base.yml
```

Equivalent direct user-phase command:

```bash
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/user.yml
```

Optional `base_sshd` integration check:

```bash
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/tests/test_base_sshd.yml --tags base_sshd
```

## Notes

- The lab content is intentionally simple and meant as an example baseline.
- The example inventory and variables assume Debian-family hosts and the repository's APT-based role behavior.
- `group_vars/all/` is split between aggregate-scoped files such as `base.yml` and `user.yml`, plus child-role files such as `base_firewall.yml` and `user_password.yml`, so aggregate toggles stay separate from child-role inputs as the stack grows.
- `base.yml` keeps the aggregate `base_include_*` toggles in one place so enabled optional base roles are easy to scan.
- `base_hosts.yml` defines the inventory-driven `/etc/hosts` baseline used when `base.yml` enables `base_hosts`.
- `base_dns.yml` defines the explicit `systemd-resolved` baseline used when `base.yml` enables `base_dns`.
- `base_firewall.yml` defines the shared firewall baseline, role-declared accumulator, and `managed:` comment convention used when `base.yml` enables `base_firewall`.
- `base_fail2ban.yml` defines the managed SSH jail baseline used when `base.yml` enables `base_fail2ban`.
- `base_logging.yml` defines the persistent journald baseline used when `base.yml` enables `base_logging`.
- `base_updates.yml` defines the unattended-upgrades baseline used when `base.yml` enables `base_updates`.
- `base_apparmor.yml` defines the AppArmor service baseline used when `base.yml` enables `base_apparmor`.
- `base_auditd.yml` defines the audit-daemon baseline used when `base.yml` enables `base_auditd`.
- `base_upgrade.yml` defines the immediate package-maintenance behavior used when `base.yml` enables `base_upgrade`.
- `base_needrestart.yml` defines the restart-check behavior used when `base.yml` enables `base_needrestart`.
- This means the example base run may fail intentionally after package maintenance when restart follow-up is still pending; set the `base_needrestart_fail_if_*` values back to `false` for report-only example runs.
- When the example run's `base_upgrade` role makes no package-maintenance changes and leaves no reboot-required follow-up, `base_needrestart` now skips the batch check automatically to reduce no-change noise.
- `playbooks/base.yml` uses `serial: 1`, which is safer when optional roles such as `base_upgrade` may reboot a host during the run.
- `user_account.yml` defines the example human admin account enforced after the base phase through the aggregate `user` role.
- `user_groups.yml` defines the example supplementary admin-group baseline, the future role-declared accumulator, and the inventory-specific follow-up layer used when `user.yml` enables `user_groups`.
- `user_sudo.yml` defines the explicit sudoers drop-in enforced for the example human admin account when `user.yml` enables `user_sudo`.
- `user.yml` enables the optional supplementary-group, sudo, and password roles in the example lab, and also keeps the documented one-run sudo-drop-in cleanup toggle near the other aggregate user switches, while `user_password.yml` sets a demo SHA-512 password hash for the example human admin account using the plaintext test password `password` and documents that a real host should use a Vault-managed hash instead.
- `ansible.cfg` sets `display_skipped_hosts = False`, so routine conditional skips from optional roles or gated tasks do not dominate the example output.
- `hosts.ini` keeps default `ansible_user=ansible` in `[all:vars]`, while `[bootstrap:vars]` holds initial login values used only during bootstrap.
- `playbooks/bootstrap.yml` prompts once for the bootstrap password and reuses it for both SSH login and sudo.
- `playbooks/tests/test_base_sshd.yml` removes its temporary SSH fixture files in an `always` block after the integration run, so the example host is returned to the normal post-test state.
- Extend the inventory, vars, and playbooks to fit your own infrastructure and test scope.
