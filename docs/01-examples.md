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
- `examples/inventory/group_vars/all/`: Example variables for all hosts, split into role-scoped files such as `bootstrap.yml`, `base_packages.yml`, `base_hostname.yml`, `base_hosts.yml`, `base_dns.yml`, `base_locale.yml`, `base_ntp.yml`, `base_sudo.yml`, `base_sshd.yml`, `base_firewall.yml`, `base_fail2ban.yml`, `base_logging.yml`, `base_updates.yml`, `base_apparmor.yml`, `base_auditd.yml`, `base_upgrade.yml`, `base_needrestart.yml`, `base_timezone.yml`, `user.yml`, `user_account.yml`, and `monitoring_authorized_key.yml`.
- `examples/playbooks/bootstrap.yml`: Bootstrap phase playbook that uses initial host credentials and applies the standalone `bootstrap` role.
- `examples/playbooks/base.yml`: Base phase playbook for post-bootstrap role execution that applies the aggregate base role one host at a time for safer reboot-capable runs.
- `examples/playbooks/user.yml`: User phase playbook for post-base role execution that applies the aggregate `user` role for human admin account enforcement.
- `examples/playbooks/site.yml`: Post-bootstrap entry playbook that imports `base.yml` and then `user.yml`.
- `examples/playbooks/tests/test_base_sshd.yml`: Optional integration test playbook for exercising merged `sshd_config.d` fragments plus `Match User` and `Match Address` behavior around the `base_sshd` role.

## How to Use the Example

1. Copy or adapt the files in `examples/` to your own lab.
2. Replace inventory hosts and credentials with your environment values.
3. Update the role-scoped files in `group_vars/all/` for your role inputs.
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
- `group_vars/all/` is split by role prefix so example variables such as `base_packages.yml`, `base_hostname.yml`, `base_hosts.yml`, `base_dns.yml`, `base_locale.yml`, `base_ntp.yml`, `base_sudo.yml`, `base_sshd.yml`, `base_firewall.yml`, `base_fail2ban.yml`, `base_logging.yml`, `base_updates.yml`, `base_apparmor.yml`, `base_auditd.yml`, `base_upgrade.yml`, `base_needrestart.yml`, `base_timezone.yml`, `user.yml`, `user_account.yml`, and `monitoring_authorized_key.yml` stay readable as the stack grows.
- `base_hosts.yml` sets `base_include_hosts: true`, which opts the example base run into the optional `base_hosts` role so example hosts can resolve inventory peer names through `/etc/hosts`.
- `base_dns.yml` sets `base_include_dns: true`, which opts the example base run into the optional `base_dns` role with an explicit `systemd-resolved` baseline.
- `base_firewall.yml` sets `base_include_firewall: true`, which opts the example base run into the optional `base_firewall` role and documents the shared baseline, role-declared accumulator, and `managed:` comment convention used for stale rule cleanup.
- `base_fail2ban.yml` sets `base_include_fail2ban: true`, which opts the example base run into the optional `base_fail2ban` role with a managed SSH jail baseline.
- `base_logging.yml` sets `base_include_logging: true`, which opts the example base run into the optional `base_logging` role with persistent journald storage enabled.
- `base_updates.yml` sets `base_include_updates: true`, which opts the example base run into the optional `base_updates` role with unattended-upgrades enabled.
- `base_apparmor.yml` sets `base_include_apparmor: true`, which opts the example base run into the optional `base_apparmor` role with the AppArmor service enabled.
- `base_auditd.yml` sets `base_include_auditd: true`, which opts the example base run into the optional `base_auditd` role with the audit daemon enabled and a minimal explicit baseline configuration.
- `base_upgrade.yml` sets `base_include_upgrade: true`, which keeps the example base run exercising immediate package maintenance so post-upgrade follow-up such as `base_needrestart` reflects the current host state.
- `base_needrestart.yml` sets `base_include_needrestart: true`, which opts the example base run into the optional `base_needrestart` role and enables strict failure flags so pending restart or reboot follow-up is surfaced immediately without restarting services automatically.
- This means the example base run may fail intentionally after package maintenance when restart follow-up is still pending; set the `base_needrestart_fail_if_*` values back to `false` for report-only example runs.
- When the example run's `base_upgrade` role makes no package-maintenance changes and leaves no reboot-required follow-up, `base_needrestart` now skips the batch check automatically to reduce no-change noise.
- `playbooks/base.yml` uses `serial: 1`, which is safer when optional roles such as `base_upgrade` may reboot a host during the run.
- `user_account.yml` defines the example human admin account enforced after the base phase through the aggregate `user` role.
- `ansible.cfg` sets `display_skipped_hosts = False`, so routine conditional skips from optional roles or gated tasks do not dominate the example output.
- `hosts.ini` keeps default `ansible_user=ansible` in `[all:vars]`, while `[bootstrap:vars]` holds initial login values used only during bootstrap.
- `playbooks/bootstrap.yml` prompts once for the bootstrap password and reuses it for both SSH login and sudo.
- `playbooks/tests/test_base_sshd.yml` removes its temporary SSH fixture files in an `always` block after the integration run, so the example host is returned to the normal post-test state.
- Extend the inventory, vars, and playbooks to fit your own infrastructure and test scope.
