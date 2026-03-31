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
  `examples/inventory/group_vars/user/`, `docker/`, `backup/`, `monitoring/`,
  and `bootstrap/`.
- Keep optional `user_*`, `docker_*`, and `monitoring_*` child-role opt-in in
  `examples/inventory/host_vars/<host>/vars.yml`.
- Put hosts in the matching inventory groups (`bootstrap`, `base`, `user`,
  `docker`, `backup`, `monitoring`) so grouped vars and playbooks line up
  cleanly.
- Keep `examples/playbooks/recurring/backup.yml` on the aggregate `backup` role so the
  recurring backup, repository init, prune, and check timers stay in the same
  steady-state path.
- Keep `examples/playbooks/recurring/monitoring.yml` on the aggregate `monitoring` role
  so host-local status generation stays on one stable entrypoint.
- Keep `examples/playbooks/ops/monitoring_ops.yml` as the aggregate operator
  entrypoint for the monitoring helper playbooks.
- Keep focused `*_now` monitoring helpers such as
  `examples/playbooks/ops/monitoring_docker_tag_now.yml` under
  `examples/playbooks/ops/` so manual validation stays separate from the
  recurring stack.
- Keep non-monitoring manual-run entrypoints explicit, such as
  `examples/playbooks/ops/bootstrap.yml`,
  `examples/playbooks/ops/base_maintenance.yml` and
  `examples/playbooks/ops/backup_restic_now.yml`, instead of reintroducing an
  aggregate ops playbook.
- Keep `examples/playbooks/recurring/base.yml` for the non-maintenance baseline and
  `examples/playbooks/ops/base_maintenance.yml` for one-host-at-a-time package
  maintenance.
- Keep `examples/playbooks/recurring/site.yml` as the post-bootstrap stack:
  `base`, `user`, `docker`, `backup`, then `monitoring`.

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
3. Enable optional `user_*`, `docker_*`, and `monitoring_*` child roles per host.
4. Keep role-specific behavior in the relevant role README instead of growing
   this document.

## Commands

For the current run commands, see [examples/README.md](../examples/README.md).
