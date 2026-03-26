# examples/README.md

Guide for the local example lab in `examples/`.
Explains the example layout and execution flow with conventions that stay stable as roles evolve.

## Scope

The example lab targets Debian-family hosts.
Variables and defaults are intentionally simple and should be adapted before production use.

## Structure

- `ansible.cfg`: example-local Ansible configuration.
- `inventory/hosts.ini`: test inventory.
- `inventory/group_vars/all/`: aggregate layer toggles plus shared switches and standalone examples.
- `inventory/group_vars/bootstrap/`: bootstrap-layer variables.
- `inventory/group_vars/base/`: recurring base-layer role inputs.
- `inventory/group_vars/user/`: recurring user-layer role inputs.
- `inventory/group_vars/docker/`: recurring Docker-layer role inputs.
- `inventory/group_vars/backup/`: recurring backup-layer role inputs.
- `inventory/group_vars/all/backup.yml`: backup-layer opt-in switch.
- `inventory/group_vars/all/secret_sources.yml`: shared secret-source switch for example playbooks.
- `inventory/host_vars/lab/vars.yml`: host-specific enable flags for optional aggregate child roles.
- `playbooks/bootstrap.yml`: bootstrap phase.
- `playbooks/base.yml`: base phase.
- `playbooks/user.yml`: user phase.
- `playbooks/docker.yml`: Docker phase.
- `playbooks/backup.yml`: backup phase.
- `playbooks/backup_restic_init.yml`: one-time backup repository bootstrap helper.
- `playbooks/backup_restic_now.yml`: on-demand backup validation helper.
- `playbooks/site.yml`: post-bootstrap entrypoint (`base`, `user`, `docker`, then `backup`).
- `playbooks/tests/`: optional integration tests.

## Variable Conventions

- Keep aggregate toggles in aggregate files (`base.yml`, `docker.yml`, `user.yml`).
- Keep the backup layer opt-in in `group_vars/all/backup.yml`.
- Keep optional aggregate `*_include_*` toggles disabled by default in `group_vars/all/`.
- Enable those optional child roles per host in `inventory/host_vars/<host>/vars.yml`.
- Keep layer-specific role inputs under the matching inventory group directory.
- Put a host in `[base]`, `[user]`, `[docker]`, `[backup]`, or `[bootstrap]` when you want that layer's grouped vars and playbook to apply.
- Add new role coverage by adding a role-scoped file and a toggle, not by rewriting this README.

## Usage

From repository root:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/bootstrap.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/site.yml
```

The example `bootstrap.yml` playbook does not prompt for credentials.
It expects the bootstrap login user and other non-secret bootstrap inputs to
come from `inventory/group_vars/bootstrap/bootstrap.yml`, with the bootstrap login
password coming from `~/.config/ansible/lab_vault.yml`, and with
`examples/ansible.cfg` explicitly pointing at
`~/.config/ansible/vault.pass`.
Keep the real encrypted secret file outside the repo at
`~/.config/ansible/lab_vault.yml`.
That external-file behavior is controlled by
`inventory/group_vars/all/secret_sources.yml` and is enabled by default for the
example lab.

Direct phase runs:

```sh
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/base.yml
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

- `playbooks/base.yml` uses `serial: 1` for safer reboot-capable runs.
- `playbooks/base.yml`, `playbooks/user.yml`, `playbooks/docker.yml`, and `playbooks/backup.yml` target the matching inventory groups so hosts opt into each recurring layer explicitly.
- The example host then opts back into the optional child roles through `inventory/host_vars/lab/vars.yml`, so the example behavior stays broad without making `group_vars/all/` implicitly enable everything for every future host.
- The example may intentionally fail when strict restart/reboot follow-up checks are enabled.
- The Docker example keeps service projects under `/srv/<service>` and
  persistent service data under `/srv/<service>/data` so backup-friendly host
  restores stay predictable.
- The backup example keeps its repository target and password in the
  controller-local Vault file so the tracked example inventory never stores
  live Restic secrets.
- The shared backup workflow now also includes one explicit first-run init
  playbook and one explicit on-demand validation playbook so consumer repos
  can follow the same operational flow shown by the example lab.
- The Docker example can optionally layer downstream services onto the shared
  Traefik proxy network, so roles such as `docker_adguard` and
  `docker_wireguard` can publish web UIs through Compose labels without adding
  more Traefik file-provider config.
- The example can also exercise sidecar roles such as `docker_adguard_sync`
  through the same aggregate-toggle-plus-role-scoped-vars pattern used by the
  other optional Docker child roles.
- The Traefik and AdGuard example URLs are derived from the inventory `alias`
  plus the Vault-backed `vault_docker_public_domain_suffix`, so an inventory host with
  `alias=proxy1` gets URLs like `traefik.proxy1.example.com` and
  `adguard.proxy1.example.com`.
- Make sure your DNS layer resolves those derived hostnames, either with
  explicit records per host or with a wildcard/rewrite pattern that matches
  the chosen domain suffix.
- Replace demo identity, password, and SSH key values before using these patterns outside a lab.

## Extending

- Add new test playbooks under `examples/playbooks/`.
- Add or update aggregate toggles in `examples/inventory/group_vars/all/`.
- Keep those aggregate toggles disabled by default unless every future example host should inherit them.
- Add layer-specific role inputs under the matching directory in `examples/inventory/group_vars/`.
- Add backup-role inputs under `examples/inventory/group_vars/backup/` when a recurring backup role is meant to track the dedicated `backup` inventory group.
- Enable optional child roles per host in `examples/inventory/host_vars/<host>/vars.yml`.
- Reuse `examples/inventory/group_vars/all/secret_sources.yml` for future playbooks that optionally load controller-local secret files.
- When a future example playbook loads that controller-local secret file, do it
  from delegated `pre_tasks` inside the target play rather than a separate
  `hosts: localhost` play so limited runs keep the same Vault-loading
  behavior.
- Keep role-specific behavior details in role READMEs so this file remains concise.
