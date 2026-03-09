# Ansible Test Lab

This directory contains a minimal local harness for validating roles in this repository.

## Structure
- `ansible.cfg`: Test-specific Ansible configuration.
- `inventory/hosts.ini`: Test inventory.
- `inventory/group_vars/all.yml`: Shared variables for test hosts.
- `playbooks/bootstrap.yml`: Bootstrap phase using the standalone `bootstrap` role.
- `playbooks/base.yml`: Normal phase (connect as automation account).
- `playbooks/site.yml`: Base-phase entry playbook that imports `base.yml`.

## Usage
Run bootstrap from repository root:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/bootstrap.yml
```

Then run the base phase:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/site.yml
```

Or run directly from the `examples/` directory:

```sh
ansible-playbook playbooks/bootstrap.yml
ansible-playbook playbooks/site.yml
```

Equivalent direct base-phase command:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/base.yml
```

## Bootstrap Credentials
The example inventory stores only the bootstrap login user:

- `bootstrap_login_user`

The bootstrap password is prompted once by `playbooks/bootstrap.yml` and reused for both SSH login and sudo.

## Extending
- Add playbooks under `examples/playbooks/`.
- Update `examples/inventory/hosts.ini` and `examples/inventory/group_vars/` as needed.
- Keep this README aligned with any new test scenarios.
