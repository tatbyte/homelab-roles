# docs/01-examples.md

Reference document for the example lab in `examples/`.
Explains how the example inventory, variables, and playbooks fit together for the bootstrap phase and the base phase on Debian-family hosts.

## Purpose

The `examples/` directory is an example environment that shows how to wire:

- inventory
- group variables
- playbooks
- `ansible.cfg`

Use it as a reference template for validating roles on your side.
The example content assumes Debian-family targets such as Debian and Ubuntu.

## Example Files

- `examples/ansible.cfg`: Example Ansible configuration for local test runs.
- `examples/inventory/hosts.ini`: Example hosts and groups.
- `examples/inventory/group_vars/all/`: Example variables for all hosts, split into role-scoped files.
- `examples/playbooks/bootstrap.yml`: Bootstrap phase playbook that uses initial host credentials and applies the standalone `bootstrap` role.
- `examples/playbooks/base.yml`: Base phase playbook for post-bootstrap role execution.
- `examples/playbooks/site.yml`: Base-phase entry playbook that imports `base.yml`.

## How to Use the Example

1. Copy or adapt the files in `examples/` to your own lab.
2. Replace inventory hosts and credentials with your environment values.
3. Update the role-scoped files in `group_vars/all/` for your role inputs.
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
- The example inventory and variables assume Debian-family hosts and the repository's APT-based role behavior.
- `group_vars/all/` is split by role prefix so example variables such as `base_packages.yml`, `base_hostname.yml`, `base_locale.yml`, `base_ntp.yml`, and `base_timezone.yml` stay readable as the base stack grows.
- `hosts.ini` keeps default `ansible_user=ansible` in `[all:vars]`, while `[bootstrap:vars]` holds initial login values used only during bootstrap.
- `playbooks/bootstrap.yml` prompts once for the bootstrap password and reuses it for both SSH login and sudo.
- Extend the inventory, vars, and playbooks to fit your own infrastructure and test scope.
