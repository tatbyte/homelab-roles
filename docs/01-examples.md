# Test Lab Example

This document describes the example lab layout provided in `examples/`.

## Purpose

The `examples/` directory is an example environment that shows how to wire:

- inventory
- group variables
- playbooks
- `ansible.cfg`

Use it as a reference template for validating roles on your side.

## Example Files

- `examples/ansible.cfg`: Example Ansible configuration for local test runs.
- `examples/inventory/hosts.ini`: Example hosts and groups.
- `examples/inventory/group_vars/all.yml`: Example variables for all hosts.
- `examples/playbooks/bootstrap.yml`: Bootstrap phase using initial host credentials and the standalone `bootstrap` role.
- `examples/playbooks/base.yml`: Normal phase for post-bootstrap role execution.
- `examples/playbooks/site.yml`: Base-phase entry playbook that imports `base.yml`.

## How to Use the Example

1. Copy or adapt the files in `examples/` to your own lab.
2. Replace inventory hosts and credentials with your environment values.
3. Update variables in `group_vars/all.yml` for your role inputs.
4. Run bootstrap first:

```bash
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/bootstrap.yml
```

5. Then run the base phase:

```bash
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/site.yml
```

Equivalent direct base-phase command:

```bash
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/base.yml
```

## Notes

- The lab content is intentionally simple and meant as an example baseline.
- `hosts.ini` keeps default `ansible_user=ansible` in `[all:vars]`, while `[bootstrap:vars]` holds initial login values used only during bootstrap.
- `playbooks/bootstrap.yml` prompts once for the bootstrap password and reuses it for both SSH login and sudo.
- Extend the inventory, vars, and playbooks to fit your own infrastructure and test scope.
