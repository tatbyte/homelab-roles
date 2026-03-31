# examples/README.md

Guide for the local example lab in `examples/`.
Explains the example inventory, playbooks, and the current execution flow.

## Scope

The example lab targets Debian-family hosts.
Values are intentionally simple and should be replaced before production use.

## Layout

- `inventory/group_vars/all/`: shared switches, non-base aggregate toggles, backup opt-in, and secret-source settings.
- `inventory/group_vars/base/`: `base_<role>_enabled` values plus base-role inputs.
- `inventory/group_vars/bootstrap/`, `user/`, `docker/`, `backup/`, `monitoring/`: layer-specific role inputs.
- `inventory/host_vars/lab/vars.yml`: host-level opt-in for optional `user_*`, `docker_*`, and `monitoring_*` child roles.
- `playbooks/ops/bootstrap.yml`: bootstrap phase.
- `playbooks/recurring/base.yml`: non-maintenance base phase.
- `playbooks/ops/base_maintenance.yml`: package maintenance with `serial: 1`.
- `playbooks/recurring/user.yml`, `docker.yml`, `backup.yml`, `monitoring.yml`: recurring layer playbooks.
- `playbooks/ops/monitoring_ops.yml`: operator-only aggregate entrypoint for
  the monitoring helper playbooks.
- `playbooks/ops/backup_restic_now.yml`: validation-only backup helper.
- `playbooks/ops/monitoring_status_now.yml`,
  `playbooks/ops/monitoring_storage_health_now.yml`,
  `playbooks/ops/monitoring_docker_tag_now.yml`,
  `playbooks/ops/monitoring_collect_now.yml`,
  `playbooks/ops/monitoring_notify_now.yml`: validation-only monitoring helpers,
  with the notify helper able to reuse an already-installed service even when
  the current local Vault file omits the ntfy URL toggle.
- `playbooks/recurring/site.yml`: post-bootstrap stack (`base`, `user`, `docker`, `backup`, `monitoring`).

For the stable layout rules behind this split, see
[docs/01-examples.md](../docs/01-examples.md).

## Usage

From repository root:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/ops/bootstrap.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/recurring/site.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/ops/base_maintenance.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/ops/backup_restic_now.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/ops/monitoring_ops.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/ops/monitoring_docker_tag_now.yml
```

The example bootstrap flow expects secrets in
`~/.config/ansible/lab_vault.yml`, with `examples/ansible.cfg` pointing at
`~/.config/ansible/vault.pass`.
That behavior is controlled by
`inventory/group_vars/all/secret_sources.yml`.

Direct phase runs:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/recurring/base.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/ops/base_maintenance.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/recurring/docker.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/recurring/backup.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/recurring/monitoring.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/ops/backup_restic_now.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/ops/monitoring_ops.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/ops/monitoring_status_now.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/ops/monitoring_docker_tag_now.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/recurring/user.yml
```

From the `examples/` directory:

```sh
ansible-playbook playbooks/ops/bootstrap.yml
ansible-playbook playbooks/recurring/site.yml
ansible-playbook playbooks/recurring/backup.yml
ansible-playbook playbooks/recurring/monitoring.yml
ansible-playbook playbooks/ops/base_maintenance.yml
ansible-playbook playbooks/ops/backup_restic_now.yml
ansible-playbook playbooks/ops/monitoring_ops.yml
ansible-playbook playbooks/ops/monitoring_status_now.yml
ansible-playbook playbooks/ops/monitoring_docker_tag_now.yml
```

Optional integration tests:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/tests/<test_name>.yml
```

## Notes

- `base.yml` is the normal baseline path. `base_maintenance.yml` is the explicit maintenance path for updates, upgrades, and reboot-capable follow-up.
- Base-role enablement lives in `inventory/group_vars/base/*.yml`.
  Optional `user_*` and `docker_*` child roles are enabled per host from
  `inventory/host_vars/lab/vars.yml`.
- `backup.yml` now runs the aggregate `backup` role, which applies the
  recurring Restic setup, initializes a missing repository, and manages the
  separate prune/check timers in the same steady-state path.
- `monitoring.yml` now runs the aggregate `monitoring` role, which currently
  applies host-local status generation through `monitoring_status`, dedicated
  storage checks through `monitoring_storage_health`, and Docker image-tag
  guidance through `monitoring_docker_tag`, including host-architecture-aware
  image-tag selection.
- There is no aggregate `playbooks/ops/site.yml` anymore. Run the specific ops
  playbook you want directly.
- The example keeps live secrets out of the repo and derives public Docker hostnames from the inventory `alias` plus `vault_docker_public_domain_suffix`.
- When the example monitoring collector needs SSH transport and the example
  Vault leaves the collector key unset, the inventory can also fall back to a
  local `~/.ssh/monitor_collect_ed25519.pub` public key on the controller.
- Keep role-specific behavior details in the relevant role README so this file stays operational and short.

## Extending

- Add new aggregate toggles under `inventory/group_vars/all/` only when they apply to a whole layer.
- Add base-role toggles and vars under `inventory/group_vars/base/`.
- Add other role inputs under the matching `inventory/group_vars/<layer>/` directory.
- Enable optional child roles per host in `inventory/host_vars/<host>/vars.yml`.
- Reuse `inventory/group_vars/all/secret_sources.yml` for future playbooks that load controller-local secrets.
