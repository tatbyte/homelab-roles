# examples/README.md

Guide for the local example lab in `examples/`.
Explains the example layout and execution flow with conventions that stay stable as roles evolve.

## Scope

The example lab targets Debian-family hosts.
Variables and defaults are intentionally simple and should be adapted before production use.

## Structure

- `ansible.cfg`: example-local Ansible configuration.
- `inventory/hosts.ini`: test inventory.
- `inventory/group_vars/all/`: aggregate toggles plus role-scoped variable files.
- `playbooks/bootstrap.yml`: bootstrap phase.
- `playbooks/base.yml`: base phase.
- `playbooks/user.yml`: user phase.
- `playbooks/docker.yml`: Docker phase.
- `playbooks/site.yml`: post-bootstrap entrypoint (`base`, `user`, then `docker`).
- `playbooks/tests/`: optional integration tests.

## Variable Conventions

- Keep aggregate toggles in aggregate files (`base.yml`, `docker.yml`, `user.yml`).
- Keep role-specific inputs in `<role>.yml`.
- Add new role coverage by adding a role-scoped file and a toggle, not by rewriting this README.

## Usage

From repository root:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/bootstrap.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/site.yml
```

The example `bootstrap.yml` playbook does not prompt for credentials.
It expects the bootstrap login user and other non-secret bootstrap inputs to
come from `inventory/group_vars/all/bootstrap.yml`, with the bootstrap login
password coming from Vault-backed vars in
`inventory/group_vars/all/bootstrap.yml`, and with `examples/ansible.cfg`
explicitly pointing at `~/.config/ansible/vault/password.txt`.
Keep only the real encrypted `vault.yml` inside `inventory/group_vars/all/`;
store any checked-in example copy outside that directory.
`bootstrap.yml` and `vault.yml` are both loaded and merged, so keep public
inputs in `bootstrap.yml` and secret values in `vault.yml`.

Direct phase runs:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/base.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/docker.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/user.yml
```

From the `examples/` directory:

```sh
ansible-playbook playbooks/bootstrap.yml
ansible-playbook playbooks/site.yml
```

Optional integration tests:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/tests/<test_name>.yml
```

## Notes

- `playbooks/base.yml` uses `serial: 1` for safer reboot-capable runs.
- The example may intentionally fail when strict restart/reboot follow-up checks are enabled.
- Replace demo identity, password, and SSH key values before using these patterns outside a lab.

## Extending

- Add new test playbooks under `examples/playbooks/`.
- Add or update aggregate and role-scoped vars in `examples/inventory/group_vars/all/`.
- Keep role-specific behavior details in role READMEs so this file remains concise.
