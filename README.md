# README.md

Repository overview for `ansible-roles`.
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
ansible-roles/
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
- `base`: Aggregates recurring base-phase configuration for Debian-family hosts through explicit `include_role` ordering in `roles/base/tasks/main.yml` for `base_packages`, `base_locale`, `base_timezone`, `base_ntp`, `base_hostname`, `base_sudo`, and `base_sshd`, with optional follow-up inclusion for `base_firewall`, `base_logging`, `base_updates`, `base_apparmor`, and `base_upgrade`.
- `base_apparmor`: Enforces a minimal AppArmor package and service baseline on Debian-family hosts during the base phase.
- `base_firewall`: Enforces an additive UFW baseline with managed default policies and requested allow or limit rules on Debian-family hosts during the base phase, with an optional purge mode for exact rebuilds.
- `base_logging`: Enforces a persistent local journald baseline on Debian-family hosts during the base phase, with an optional volatile mode for non-persistent logs.
- `base_upgrade`: Applies an explicit APT upgrade pass with optional autoremove and reboot handling on Debian-family hosts during the base phase.
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
Recommended pattern: add this repository to your infra repository (submodule or vendored checkout), then point `roles_path` to `ansible-roles/roles`.

Example infra repo `ansible.cfg`:

```ini
[defaults]
inventory = ./inventory/hosts.ini
roles_path = ./roles:./vendor/ansible-roles/roles
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
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/test_base_sshd.yml --tags base_sshd
```

Or from the `examples/` directory:

```sh
ansible-playbook playbooks/bootstrap.yml
ansible-playbook playbooks/site.yml
```

See [examples/README.md](examples/README.md) and [docs/01-examples.md](docs/01-examples.md) for lab details.

## Linting
Pre-commit and linting are configured in this repository.

Quick start:

```sh
pre-commit install
pre-commit run --all-files
```

See [docs/00-pre-commit.mb](docs/00-pre-commit.mb) for full setup details.

## Documentation
Core repository docs:

- [docs/01-examples.md](docs/01-examples.md): Example lab layout and execution flow
- [docs/02-role-workflow.md](docs/02-role-workflow.md): Shared role phase structure and aggregate base-role ordering
- [docs/03-file-consistency.md](docs/03-file-consistency.md): File header and wording consistency rules

## License
MIT
