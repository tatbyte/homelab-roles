# Ansible Test Lab

This directory contains a minimal test lab setup for validating roles in this repository.

## Structure
- `ansible.cfg`: Ansible configuration for the test lab.
- `inventory/hosts.yml`: Inventory file with a local test host.
- `inventory/group_vars/all.yml`: Global variables for all hosts.
- `playbooks/base_bootstrap.yml`: Playbook to test the `base_bootstrap` role.
- `playbooks/site.yml`: Playbook to test the `base` role.

## Usage
Run a test playbook:

```sh
ansible-playbook -i inventory/hosts.yml playbooks/base_bootstrap.yml
```

# Tests Documentation

This document explains the structure and purpose of the files in the `tests/` directory for this Ansible roles repository.

## Overview
The `tests/` directory contains resources for validating and verifying the functionality of the Ansible roles. It is designed to help ensure that roles work as expected in different environments and configurations.

## Directory Structure
- **ansible.cfg**: Custom Ansible configuration for running tests. Adjusts settings such as inventory location and roles path for the test environment.
- **README.md**: This file (you are reading it) explains the test setup and usage.
- **inventory/**: Contains inventory files and group variables for test runs.
  - **hosts.ini**: Defines hosts and groups for testing.
  - **group_vars/**: Contains variable files for host groups, e.g., `all.yml` for variables applied to all hosts.
- **playbooks/**: Contains playbooks used for testing roles.
  - **base_bootstrap.yml**: Playbook to test the `base_bootstrap` role.
  - **site.yml**: Main test playbook, can include multiple roles and scenarios.

## How to Run Tests
1. Ensure you have Ansible installed.
2. From the `tests/` directory, run a playbook, e.g.:
   ```bash
   ansible-playbook -i inventory/hosts.ini playbooks/site.yml
   ```
3. Review output for any errors or failed tasks.

## Adding New Tests
- Add new playbooks to the `playbooks/` directory.
- Update `inventory/hosts.ini` and `group_vars/` as needed for new scenarios.
- Document any new test cases in this README.

## Purpose
Testing ensures:
- Roles are idempotent and reliable.
- Variables and defaults work as intended.
- Role dependencies are satisfied.
- Configuration changes do not break existing functionality.

---
For questions or improvements, update this README or contact the repository maintainers.
