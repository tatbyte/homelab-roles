# docs/01-examples.md

Reference document for the example lab in `examples/`.
Explains the stable layout rules behind the example lab without duplicating the runbook in `examples/README.md`.

## Purpose

The `examples/` directory is the local validation harness for this repository.
Use it as the template for:

- inventory layout
- aggregate toggles
- role-scoped variable files
- bootstrap and post-bootstrap playbook flow

The example assumes Debian-family hosts.

## Layout Rules

- Keep shared switches and non-base aggregate toggles in
  `examples/inventory/group_vars/all/`.
- Keep base-role enablement and base-role inputs in
  `examples/inventory/group_vars/base/` with the `base_<role>_enabled` pattern.
- Keep other role inputs under the matching layer directory such as
  `examples/inventory/group_vars/user/`, `docker/`, `backup/`, and
  `bootstrap/`.
- Keep optional `user_*` and `docker_*` child-role opt-in in
  `examples/inventory/host_vars/<host>/vars.yml`.
- Put hosts in the matching inventory groups (`bootstrap`, `base`, `user`,
  `docker`, `backup`) so grouped vars and playbooks line up cleanly.
- Keep `examples/playbooks/base.yml` for the non-maintenance baseline and
  `examples/playbooks/base_maintenance.yml` for one-host-at-a-time package
  maintenance.
- Keep `examples/playbooks/site.yml` as the post-bootstrap stack:
  `base`, `user`, `docker`, then `backup`.

## Secret Loading

- Keep live secrets outside the repo in `~/.config/ansible/lab_vault.yml`.
- Keep the Vault password file at `~/.config/ansible/vault.pass`, which the
  example `ansible.cfg` expects by default.
- Reuse `examples/inventory/group_vars/all/secret_sources.yml` for playbooks
  that optionally load controller-local secrets.
- When a playbook loads that local file, do it from delegated `pre_tasks`
  inside the target play so `--limit <host>` keeps the same behavior.

## Adding Or Changing Coverage

1. Add or update the aggregate toggle in the correct source-of-truth location.
2. Add or update one role-scoped vars file under the matching layer directory.
3. Enable optional `user_*` and `docker_*` child roles per host.
4. Keep role-specific behavior in the relevant role README instead of growing
   this document.

## Commands

For the current run commands, see [examples/README.md](../examples/README.md).
