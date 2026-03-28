# README.md

Repository overview for `homelab-roles`.
Explains the role collection, how to consume it from another repo, and where the example lab fits.

## Overview
This repository contains reusable Ansible roles for a Debian-family homelab.
It is meant to be consumed by a separate infra repo that owns inventory, secrets, and environment-specific playbooks.
The `examples/` directory is the local validation harness for the shared roles.

## Role Families

- `bootstrap`: initial automation-account setup.
- `base`: recurring host baseline, hardening, and maintenance building blocks.
- `user`: recurring human-admin account and shell/tooling workflow.
- `docker`: Docker engine plus optional service roles.
- `backup_restic`, `backup_restic_init`, `backup_restic_now`: recurring backup plus init and validation helpers.
- `monitoring` and focused standalone roles: supporting capabilities consumed directly or through aggregates.

## Supported Platforms
This repository currently targets Debian-family hosts such as Debian and Ubuntu.
Role implementations, package-management tasks, and example configuration assume APT and Debian-family filesystem conventions.

## Repository Layout

- `roles/`: shared aggregate and standalone roles.
- `examples/`: local lab inventory and playbooks for validating this repo.
- `docs/`: repository conventions that apply across roles.

Role details live in `roles/<role>/README.md`.
Aggregate execution order lives in `roles/base/tasks/main.yml`, `roles/user/tasks/main.yml`, and `roles/docker/tasks/main.yml`.

## Docker Role Conventions

When adding future `docker_*` roles in this repository:

- keep one Docker package family per host; do not mix distro `docker.io` hosts with Docker Inc. plugin packages on the same machine unless that host is intentionally managed that way
- keep Compose support in the same package family as the Docker engine on that host
- make the Compose command configurable so a host can use either `docker compose` or classic `docker-compose`
- keep host-family differences in the consumer inventory `host_vars`, not hardcoded into shared role logic
- keep host-side persistent state under `/srv/<service>` with data under `/srv/<service>/data` unless a role has a strong reason to differ
- document any firewall rules, proxy-network assumptions, and first-run initialization caveats in the role README

## Consume From Another Repo

Recommended pattern: add this repo to your infra repo, then point `roles_path`
at `homelab-roles/roles`.

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
  hosts: base
  become: true
  roles:
    - role: base

- name: Apply human admin user setup
  hosts: user
  become: true
  roles:
    - role: user

- name: Apply Docker setup
  hosts: docker
  become: true
  roles:
    - role: docker

- name: Apply backup schedule
  hosts: backup
  become: true
  roles:
    - role: backup_restic

- name: Apply monitoring access
  hosts: monitoring_targets
  become: true
  roles:
    - role: monitoring_authorized_key
```

## Local Role Testing

Run the example lab from repo root:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/bootstrap.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/site.yml
```

Dedicated maintenance stays separate:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/base_maintenance.yml
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

See [examples/README.md](examples/README.md) for the runbook and
[docs/01-examples.md](docs/01-examples.md) for the stable layout rules.

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

- [docs/01-examples.md](docs/01-examples.md): Example lab layout rules and secret-loading pattern
- [docs/02-role-workflow.md](docs/02-role-workflow.md): Shared role phase structure and aggregate toggle conventions
- [docs/03-file-consistency.md](docs/03-file-consistency.md): File header and wording consistency rules
- [docs/04-firewall-role-integration.md](docs/04-firewall-role-integration.md): How future roles should register firewall rules for `base_firewall`
- [docs/05-vault.md](docs/05-vault.md): Vault guidance for the example lab and secret-bearing role inputs
- [docs/06-user-groups-role-integration.md](docs/06-user-groups-role-integration.md): How future roles should register human admin supplementary-group needs for `user_groups`
- [docs/07-docker-role-conventions.md](docs/07-docker-role-conventions.md): Shared Docker daemon, access-group, and backup-path conventions
- [docs/08-docker-traefik-downstream-services.md](docs/08-docker-traefik-downstream-services.md): How future Docker service roles should join Traefik, publish direct host ports, and split host-versus-container listeners safely

## License
MIT
