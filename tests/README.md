# Ansible Test Lab

This directory contains a minimal local harness for validating roles in this repository.

## Structure
- `ansible.cfg`: Test-specific Ansible configuration.
- `inventory/hosts.ini`: Test inventory.
- `inventory/group_vars/all.yml`: Shared variables for test hosts.
- `playbooks/base.yml`: Runs the `base` role test.
- `playbooks/site.yml`: Entry playbook that imports `base.yml`.

## Usage
Run from repository root:

```sh
ANSIBLE_CONFIG=tests/ansible.cfg ansible-playbook tests/playbooks/site.yml
```

Or run directly from the `tests/` directory:

```sh
ansible-playbook -i inventory/hosts.ini playbooks/site.yml
```

## Adding Tests
- Add playbooks under `tests/playbooks/`.
- Update `tests/inventory/hosts.ini` and `tests/inventory/group_vars/` as needed.
- Keep this README aligned with any new test scenarios.
