# ansible-roles

Reusable Ansible roles for homelab and infrastructure automation.

## Overview
This repository is a roles source repository. It is intended to be consumed by a separate infra repository that contains your environment-specific inventory and playbooks.

## Repository Layout
```text
ansible-roles/
├── roles/
│   ├── base/
│   ├── base_bootstrap/
│   ├── monitoring/
│   └── monitoring_authorized_key/
├── tests/
│   ├── ansible.cfg
│   ├── inventory/
│   └── playbooks/
├── docs/
├── CHANGELOG.md
└── README.md
```

## Available Roles
- `base`: Aggregate role that currently depends on `base_bootstrap`.
- `base_bootstrap`: Creates and validates a bootstrap/admin user and SSH access.
- `monitoring`: Aggregate role that currently depends on `monitoring_authorized_key`.
- `monitoring_authorized_key`: Installs an SSH authorized key for monitoring-style access.

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
This repository keeps a local test harness in `tests/`.

Run tests from repo root:

```sh
ANSIBLE_CONFIG=tests/ansible.cfg ansible-playbook tests/playbooks/base.yml
```

See [tests/README.md](tests/README.md) and [docs/01-test-lab.md](docs/01-test-lab.md) for test-lab details.

## Linting
Pre-commit and linting are configured in this repository.

Quick start:

```sh
pre-commit install
pre-commit run --all-files
```

See [docs/00-pre-commit.mb](docs/00-pre-commit.mb) for full setup details.

## License
MIT
