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
- recurring human admin account management
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
│   ├── base/                  # aggregate base workflow
│   ├── user/                  # aggregate human-admin workflow
│   ├── bootstrap/             # bootstrap-phase automation account setup
│   ├── monitoring/            # aggregate monitoring workflow
│   └── <role_name>/           # standalone and aggregate child roles
├── examples/
│   ├── ansible.cfg
│   ├── inventory/
│   └── playbooks/
├── docs/
├── CHANGELOG.md
└── README.md
```

## Available Roles
- `bootstrap`: standalone bootstrap role for initial automation-account setup.
- `base`: aggregate base-phase role with required foundation plus optional hardening and maintenance child roles.
- `user`: aggregate human-admin role with account baseline plus optional user-environment child roles.
- `monitoring`: aggregate monitoring namespace currently delegating to focused monitoring child roles.
- `base_*`, `user_*`, and other standalone roles: focused capabilities grouped by domain and consumed either directly or via aggregate roles.

Role details live in each role README under `roles/<role>/README.md`.
Aggregate execution order is documented by, and sourced from, `roles/base/tasks/main.yml` and `roles/user/tasks/main.yml`.

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

- name: Apply human admin user setup
  hosts: all
  become: true
  roles:
    - role: user

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

The example bootstrap flow expects its login password to come from
Vault-backed variables in inventory YAML, and the example Ansible config
explicitly uses `~/.config/ansible/vault/password.txt` as the Vault password
file path.

Then run the full post-bootstrap stack:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/site.yml
```

Equivalent direct user-phase command:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/user.yml
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
The current example lab also enables a representative set of optional `user_*` roles so the human-admin layer exercises account access, shell/profile, workspace, and editor/Git workflows; replace example identity values, password material, and demo SSH keys before using the pattern on real hosts.

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
- [docs/02-role-workflow.md](docs/02-role-workflow.md): Shared role phase structure and aggregate base-role plus user-role ordering
- [docs/03-file-consistency.md](docs/03-file-consistency.md): File header and wording consistency rules
- [docs/04-firewall-role-integration.md](docs/04-firewall-role-integration.md): How future roles should register firewall rules for `base_firewall`
- [docs/05-vault.md](docs/05-vault.md): Short Vault guidance for secret-bearing inventory values such as `user_password`
- [docs/06-user-groups-role-integration.md](docs/06-user-groups-role-integration.md): How future roles should register human admin supplementary-group needs for `user_groups`

## License
MIT
