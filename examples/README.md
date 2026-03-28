# examples/README.md

Guide for the local example lab in `examples/`.
Explains the example inventory, playbooks, and the current execution flow.

## Scope

The example lab targets Debian-family hosts.
Values are intentionally simple and should be replaced before production use.

## Layout

- `inventory/group_vars/all/`: shared switches, non-base aggregate toggles, backup opt-in, and secret-source settings.
- `inventory/group_vars/base/`: `base_<role>_enabled` values plus base-role inputs.
- `inventory/group_vars/bootstrap/`, `user/`, `docker/`, `backup/`: layer-specific role inputs.
- `inventory/host_vars/lab/vars.yml`: host-level opt-in for optional `user_*` and `docker_*` child roles.
- `playbooks/bootstrap.yml`: bootstrap phase.
- `playbooks/base.yml`: non-maintenance base phase.
- `playbooks/base_maintenance.yml`: package maintenance with `serial: 1`.
- `playbooks/user.yml`, `docker.yml`, `backup.yml`: recurring layer playbooks.
- `playbooks/backup_restic_init.yml`, `backup_restic_now.yml`: operational backup helpers.
- `playbooks/site.yml`: post-bootstrap stack (`base`, `user`, `docker`, `backup`).

For the stable layout rules behind this split, see
[docs/01-examples.md](../docs/01-examples.md).

## Usage

From repository root:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/bootstrap.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/site.yml
```

The example bootstrap flow expects secrets in
`~/.config/ansible/lab_vault.yml`, with `examples/ansible.cfg` pointing at
`~/.config/ansible/vault.pass`.
That behavior is controlled by
`inventory/group_vars/all/secret_sources.yml`.

Direct phase runs:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/base.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/base_maintenance.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/docker.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/backup.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/backup_restic_init.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/backup_restic_now.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/user.yml
```

From the `examples/` directory:

```sh
ansible-playbook playbooks/bootstrap.yml
ansible-playbook playbooks/site.yml
ansible-playbook playbooks/backup.yml
ansible-playbook playbooks/backup_restic_init.yml
ansible-playbook playbooks/backup_restic_now.yml
```

Optional integration tests:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/tests/<test_name>.yml
```

## Notes

- `base.yml` is the normal baseline path. `base_maintenance.yml` is the explicit maintenance path for updates, upgrades, and reboot-capable follow-up.
- Base-role enablement lives in `inventory/group_vars/base/*.yml`. Optional `user_*` and `docker_*` child roles are enabled per host from `inventory/host_vars/lab/vars.yml`.
- The example keeps live secrets out of the repo and derives public Docker hostnames from the inventory `alias` plus `vault_docker_public_domain_suffix`.
- Keep role-specific behavior details in the relevant role README so this file stays operational and short.

## Extending

- Add new aggregate toggles under `inventory/group_vars/all/` only when they apply to a whole layer.
- Add base-role toggles and vars under `inventory/group_vars/base/`.
- Add other role inputs under the matching `inventory/group_vars/<layer>/` directory.
- Enable optional child roles per host in `inventory/host_vars/<host>/vars.yml`.
- Reuse `inventory/group_vars/all/secret_sources.yml` for future playbooks that load controller-local secrets.
