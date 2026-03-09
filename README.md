# README.md

Repository overview for `ansible-roles`.
Explains the role collection layout, the intended consumption pattern from another repository, and the local example workflow.

## Overview
This repository is a roles source repository. It is intended to be consumed by a separate infra repository that contains your environment-specific inventory and playbooks.

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
- `base`: Aggregates recurring base-phase configuration for Debian-family hosts through dependency roles such as `base_packages`, `base_ntp`, and `base_timezone`.
- `base_locale`: Ensures requested locales exist and configures the system default locale on Debian-family hosts during the base phase.
- `base_ntp`: Configures system time synchronization through `systemd-timesyncd` on Debian-family hosts during the base phase.
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
- [docs/02-role-workflow.md](docs/02-role-workflow.md): Shared role phase structure
- [docs/03-file-consistency.md](docs/03-file-consistency.md): File header and wording consistency rules

## License
MIT
