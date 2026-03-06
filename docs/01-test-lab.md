# Test Lab Setup

This document describes the test-lab setup used to validate roles in this repository.

## Purpose
The test lab provides a controlled environment for validating Ansible roles and playbooks. It uses the files in the `tests/` directory to define hosts, variables, and playbooks for automated testing.

## Key Files
- `tests/inventory/hosts.ini`: Defines the hosts and groups used in test scenarios.
- `tests/inventory/group_vars/all.yml`: Sets variables for all hosts in the test inventory.
- `tests/playbooks/base.yml`: Playbook for testing the `base` role.
- `tests/playbooks/site.yml`: Entry playbook that imports `base.yml`.

## Usage
1. Review and edit `hosts.ini` to match your test environment.
2. Adjust variables in `group_vars/all.yml` as needed.
3. Run tests from the repository root:
   ```bash
   ANSIBLE_CONFIG=tests/ansible.cfg ansible-playbook tests/playbooks/site.yml
   ```
4. Or run from the `tests/` directory:
   ```bash
   ansible-playbook -i inventory/hosts.ini playbooks/site.yml
   ```

## Customization
- Add new hosts or groups to `hosts.ini` for expanded scenarios.
- Create additional playbooks in `playbooks/` to test new roles or features.
- Update group variables for specific test requirements.

---
For more details, see the main tests/README.md or contact the maintainers.
