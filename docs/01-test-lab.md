# 01-test-lab.md

# Test Lab Setup

This document describes the initial setup and structure for the test lab in this repository.

## Purpose
The test lab provides a controlled environment for validating Ansible roles and playbooks. It uses the files in the `tests/` directory to define hosts, variables, and playbooks for automated testing.

## Key Files
- `tests/inventory/hosts.ini`: Defines the hosts and groups used in test scenarios.
- `tests/inventory/group_vars/all.yml`: Sets variables for all hosts in the test inventory.
- `tests/playbooks/base_bootstrap.yml`: Example playbook for testing the `base_bootstrap` role.
- `tests/playbooks/site.yml`: Main playbook for running comprehensive tests across roles.

## Usage
1. Review and edit `hosts.ini` to match your test environment.
2. Adjust variables in `group_vars/all.yml` as needed.
3. Run playbooks from the `tests/` directory using Ansible:
   ```bash
   ansible-playbook -i inventory/hosts.ini playbooks/site.yml
   ```

## Customization
- Add new hosts or groups to `hosts.ini` for expanded scenarios.
- Create additional playbooks in `playbooks/` to test new roles or features.
- Update group variables for specific test requirements.

---
For more details, see the main tests/README.md or contact the maintainers.
