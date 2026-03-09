# ansible-roles

Reusable Ansible roles for homelab and infrastructure automation.

## Overview
This repository is a roles source repository. It is intended to be consumed by a separate infra repository that contains your environment-specific inventory and playbooks.

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
- `base`: Aggregate role for recurring base configuration (currently `base_packages`).
- `bootstrap`: Creates and validates the automation account used by later plays (for example `ansible`).
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

## License
MIT
