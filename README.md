# README.md

Repository overview for `homelab-roles`.
Explains the role collection layout, the intended consumption pattern from another repository, and the local example workflow.

## Overview
This repository is a personal Ansible role collection for managing a homelab across multiple hosts.
It is intended to be consumed by a separate infra repository that contains your environment-specific inventory and playbooks, while `examples/` provides a local validation harness for the roles themselves.

It is being built to learn Ansible and Linux at the same time through repeatable, real-world automation instead of one-off host changes.
The goal is to keep host setup explicit, rebuildable, and easy to evolve over time so it can serve as a solid baseline for backup, monitoring, recovery, and host recreation workflows in a small self-hosted environment.

## Current Focus
The current role set is centered on:

- bootstrap access for the automation account
- recurring base host configuration and hardening
- monitoring-related access primitives

This is a roles repository, not the full infrastructure repository.
Inventory, host grouping, secrets, and environment-specific playbooks are expected to live in a separate consumer repo.

## Supported Platforms
This repository currently targets Debian-family hosts such as Debian and Ubuntu.
Role implementations, package-management tasks, and example configuration assume APT and Debian-family filesystem conventions.

## Repository Layout
```text
homelab-roles/
├── roles/
│   ├── base/
│   ├── bootstrap/
│   ├── monitoring/
│   └── monitoring_authorized_key/
├── examples/
│   ├── ansible.cfg
│   ├── inventory/
│   └── playbooks/
├── docs/
├── CHANGELOG.md
└── README.md
```

## Available Roles
- `bootstrap`: Creates and validates the automation account used after the bootstrap phase.
- `base`: Aggregates recurring base-phase configuration for Debian-family hosts through explicit `include_role` ordering in `roles/base/tasks/main.yml` for `base_packages`, `base_locale`, `base_timezone`, `base_ntp`, `base_hostname`, optional `base_hosts`, optional `base_dns`, `base_sudo`, and `base_sshd`, with optional follow-up inclusion for `base_firewall`, `base_fail2ban`, `base_logging`, `base_updates`, `base_apparmor`, `base_auditd`, `base_upgrade`, and `base_needrestart`.
- `base_apparmor`: Enforces a minimal AppArmor package and service baseline on Debian-family hosts during the base phase.
- `base_auditd`: Enforces a minimal Linux audit daemon package, service, and baseline configuration on Debian-family hosts during the base phase.
- `base_dns`: Enforces a minimal DNS resolver baseline through `systemd-resolved` on Debian-family hosts during the base phase.
- `base_fail2ban`: Enforces a minimal Fail2ban package, service, and SSH jail baseline on Debian-family hosts during the base phase.
- `base_firewall`: Enforces an additive UFW baseline with managed default policies, aggregated base plus role-declared plus explicit rules, and stale cleanup for `managed:`-prefixed role-owned UFW rules on Debian-family hosts during the base phase, with an optional purge mode for exact rebuilds.
- `base_hosts`: Enforces inventory-driven and optional manual cluster host mappings through a managed `/etc/hosts` block on Debian-family hosts during the base phase.
- `base_logging`: Enforces a persistent local journald baseline on Debian-family hosts during the base phase, with an optional volatile mode for non-persistent logs.
- `base_needrestart`: Runs `needrestart` in non-interactive batch mode and exposes pending service-restart or reboot follow-up state on Debian-family hosts during the base phase, while skipping the check automatically only when the same run's `base_upgrade` role reported no package-maintenance changes and no reboot-required follow-up.
- `base_upgrade`: Applies an explicit APT upgrade pass with optional autoremove and reboot handling on Debian-family hosts during the base phase, and exposes package-maintenance change facts for downstream roles.
- `base_updates`: Enforces a minimal unattended-upgrades baseline on Debian-family hosts during the base phase through managed APT periodic policy files.
- `base_hostname`: Enforces the system hostname on Debian-family hosts during the base phase.
- `base_locale`: Ensures requested locales exist and configures the system default locale on Debian-family hosts during the base phase.
- `base_ntp`: Configures system time synchronization through `systemd-timesyncd` on Debian-family hosts during the base phase.
- `base_sudo`: Enforces recurring sudo-group membership and a managed passwordless sudo policy on Debian-family hosts during the base phase.
- `base_sshd`: Enforces a managed SSH daemon baseline through a dedicated `sshd_config.d` drop-in on Debian-family hosts during the base phase.
- `base_timezone`: Enforces the system timezone on Debian-family hosts during the base phase.
- `monitoring`: Aggregates monitoring-related configuration through dependency roles such as `monitoring_authorized_key`.
- `monitoring_authorized_key`: Installs an SSH authorized key for monitoring-style inter-host access.

## Consume From Another Repo
Recommended pattern: add this repository to your infra repository (submodule or vendored checkout), then point `roles_path` to `homelab-roles/roles`.

Example infra repo `ansible.cfg`:

```ini
[defaults]
inventory = ./inventory/hosts.ini
roles_path = ./roles:./vendor/homelab-roles/roles
```

Example infra playbook:

```yaml
---
- name: Bootstrap hosts using initial admin access
  hosts: bootstrap
  become: true
  roles:
    - role: bootstrap

- name: Apply base setup
  hosts: all
  become: true
  roles:
    - role: base

- name: Apply monitoring access
  hosts: monitoring_targets
  become: true
  roles:
    - role: monitoring_authorized_key
```

## Local Role Testing
This repository keeps a local test harness in `examples/`.

Run bootstrap first from repo root:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/bootstrap.yml
```

Then run the base phase:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/site.yml
```

Optional `base_sshd` integration check:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/tests/test_base_sshd.yml --tags base_sshd
```

Or from the `examples/` directory:

```sh
ansible-playbook playbooks/bootstrap.yml
ansible-playbook playbooks/site.yml
```

See [examples/README.md](examples/README.md) and [docs/01-examples.md](docs/01-examples.md) for lab details.
The current example lab intentionally keeps `base_upgrade` and strict `base_needrestart` follow-up enabled, so a base run may fail when pending reboot or service-restart work is detected after upgrades.

## Linting
Pre-commit and linting are configured in this repository.

Quick start:

```sh
pipx install ansible-lint
pipx install ggshield
ggshield auth login
pre-commit install
pre-commit run --all-files
```

`ggshield` authentication is required before the repository's GitGuardian hooks can run on commits and pushes.
If you only want the local formatting and lint hooks for a short session, you can temporarily skip GitGuardian with `SKIP=ggshield,ggshield-push pre-commit run --all-files`.
Use `pre-commit run ggshield --all-files` and `pre-commit run ggshield-push --hook-stage pre-push` when you want to validate the GitGuardian commit and push stages explicitly.

See [docs/00-pre-commit.mb](docs/00-pre-commit.mb) for full setup details.

## Documentation
Core repository docs:

- [docs/01-examples.md](docs/01-examples.md): Example lab layout and execution flow
- [docs/02-role-workflow.md](docs/02-role-workflow.md): Shared role phase structure and aggregate base-role ordering
- [docs/03-file-consistency.md](docs/03-file-consistency.md): File header and wording consistency rules
- [docs/04-firewall-role-integration.md](docs/04-firewall-role-integration.md): How future roles should register firewall rules for `base_firewall`

## License
MIT
