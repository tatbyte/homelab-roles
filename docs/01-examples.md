# docs/01-examples.md

Reference document for the example lab in `examples/`.
Explains how the example inventory, variables, and playbooks fit together without requiring per-role documentation updates.

## Purpose

The `examples/` directory is a reusable lab scaffold for validating roles.
Use it as a template for:

- inventory layout
- aggregate role toggles
- role-scoped variable files
- bootstrap and post-bootstrap playbook flow

The example assumes Debian-family hosts.

## Example Files

- `examples/ansible.cfg`: local Ansible configuration for the example lab.
- `examples/inventory/hosts.ini`: test hosts and groups.
- `examples/inventory/group_vars/all/`: aggregate and role-scoped variables.
- `examples/playbooks/bootstrap.yml`: bootstrap-phase playbook.
- `examples/playbooks/base.yml`: base-phase playbook.
- `examples/playbooks/user.yml`: user-phase playbook.
- `examples/playbooks/docker.yml`: Docker-phase playbook.
- `examples/playbooks/site.yml`: post-bootstrap entrypoint (`base`, `user`, then `docker`).
- `examples/playbooks/tests/`: optional integration test playbooks.

## Variable Layout Convention

- Keep aggregate toggles in aggregate files such as `base.yml`, `docker.yml`, and `user.yml`.
- Keep child role inputs in role-scoped files named `<role>.yml`.
- Use this split consistently so adding a role usually means:
1. add one toggle in an aggregate file
2. add one role-scoped variable file
3. no broad documentation rewrites

## Usage

Run bootstrap first:

```bash
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/bootstrap.yml
```

Then run the post-bootstrap stack:

```bash
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/site.yml
```

Equivalent direct phase runs:

```bash
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/base.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/docker.yml
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/user.yml
```

Optional integration tests:

```bash
ANSIBLE_CONFIG=examples/ansible.cfg ansible-playbook examples/playbooks/tests/<test_name>.yml
```

## Notes

- `playbooks/base.yml` uses `serial: 1` to reduce risk for reboot-capable runs.
- `playbooks/bootstrap.yml` expects Vault-backed bootstrap credentials from
  `~/.config/ansible/vault.yml` rather than prompting interactively, using the
  example inventory layout and the Vault password file configured in
  `examples/ansible.cfg`.
- Keep only active inventory vars files inside `inventory/group_vars/all/`;
  move any examples elsewhere so Ansible does not auto-load them.
- Keep public example vars in `inventory/group_vars/all/` and keep the real
  secret file outside the repo at `~/.config/ansible/vault.yml`.
- The Docker example keeps service projects under `/srv/<service>` and
  persistent data under `/srv/<service>/data` so backup and restore behavior
  stays aligned with the repository Docker conventions.
- The Docker example can also layer downstream services onto the shared
  Traefik proxy network, so service roles such as `docker_adguard` and
  `docker_wireguard` can expose web UIs through Compose labels while still
  keeping host data under `/srv`.
- The example Docker layer derives Traefik and AdGuard web URLs from the
  inventory `alias` plus the Vault-backed
  `vault_docker_public_domain_suffix`, so each host can keep a predictable
  per-host dashboard URL without repeating full FQDNs in Vault.
- Make sure your DNS layer resolves those derived hostnames, either with
  explicit records such as `traefik.proxy1.example.com` and
  `adguard.proxy1.example.com`, or with a wildcard/rewrite rule that covers
  the chosen public suffix.
- Example values are intentionally demo-friendly; replace identity, password, and key material before production use.
- Keep role-specific behavior documentation in each role README so this example guide stays stable as roles are added.
