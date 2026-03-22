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
- `inventory/group_vars/all/secret_sources.yml`: shared secret-source switch for example playbooks.
- `inventory/host_vars/lab/vars.yml`: host-specific enable flags for optional aggregate child roles.
- `playbooks/bootstrap.yml`: bootstrap phase.
- `playbooks/base.yml`: base phase.
- `playbooks/user.yml`: user phase.
- `playbooks/docker.yml`: Docker phase.
- `playbooks/site.yml`: post-bootstrap entrypoint (`base`, `user`, then `docker`).
- `playbooks/tests/`: optional integration tests.

## Variable Conventions

- Keep aggregate toggles in aggregate files (`base.yml`, `docker.yml`, `user.yml`).
- Keep optional aggregate `*_include_*` toggles disabled by default in `group_vars/all/`.
- Enable those optional child roles per host in `inventory/host_vars/<host>/vars.yml`.
- Keep layer-specific role inputs under the matching inventory group directory.
- Put a host in `[base]`, `[user]`, `[docker]`, or `[bootstrap]` when you want that layer's grouped vars and playbook to apply.
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
- `playbooks/base.yml`, `playbooks/user.yml`, and `playbooks/docker.yml` now target the matching inventory groups `base`, `user`, and `docker` so hosts opt into each recurring layer explicitly.
- The example host then opts back into the optional child roles through `inventory/host_vars/lab/vars.yml`, so the example behavior stays broad without making `group_vars/all/` implicitly enable everything for every future host.
- The example may intentionally fail when strict restart/reboot follow-up checks are enabled.
- The Docker example keeps service projects under `/srv/<service>` and
  persistent service data under `/srv/<service>/data` so backup-friendly host
  restores stay predictable.
- The Docker example can optionally layer downstream services onto the shared
  Traefik proxy network, so roles such as `docker_adguard` and
  `docker_wireguard` can publish web UIs through Compose labels without adding
  more Traefik file-provider config.
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
- Enable optional child roles per host in `examples/inventory/host_vars/<host>/vars.yml`.
- Reuse `examples/inventory/group_vars/all/secret_sources.yml` for future playbooks that optionally load controller-local secret files.
- Keep role-specific behavior details in role READMEs so this file remains concise.
