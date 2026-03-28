# docs/02-role-workflow.md

Reference for the shared role lifecycle used in this repository.
Explains the standard phase model and aggregate-role conventions in a maintenance-friendly way.

## Standard Phases

1. `assert`
2. `install`
3. `config`
4. `validate`

Not every role needs every phase.
Use only the phases that make sense, but keep `tasks/main.yml` as the stable phase entrypoint when phases are present.

## Phase Intent

- `assert`: validate inputs and fail early.
- `install`: install prerequisites needed before configuration.
- `config`: enforce desired state idempotently.
- `validate`: verify resulting state explicitly.

## Recommended Task Entrypoint

```yaml
---
- name: Assert
  ansible.builtin.import_tasks: assert.yml
  tags: [assert]

- name: Install
  ansible.builtin.import_tasks: install.yml
  tags: [install]

- name: Config
  ansible.builtin.import_tasks: config.yml
  tags: [config]

- name: Validate
  ansible.builtin.import_tasks: validate.yml
  tags: [validate]
```

## Aggregate Role Conventions

For aggregate roles such as `base`, `docker`, `user`, `backup`, and
`monitoring`:

- Keep execution order explicit with `ansible.builtin.include_role` in `tasks/main.yml`.
- Keep required baseline roles first, then optional follow-up roles.
- Gate optional child roles with the aggregate pattern that matches that layer.
- For `base`, prefer role-scoped `base_<role>_enabled` inputs in the matching
  `group_vars/base/<role>.yml` file, with legacy `base_include_*` values kept
  only as compatibility fallbacks inside the aggregate role.
- For `user`, `docker`, `backup`, and `monitoring`, keep aggregate toggles
  such as `user_include_*`.
- Keep include-task tags aligned with child role phase tags and role-specific tags.
- Treat aggregate `tasks/main.yml` as the source of truth for current order.

This avoids frequent documentation churn when new child roles are introduced.

## Adding A New Optional Child Role

1. Add an explicit `include_role` entry in the aggregate `tasks/main.yml`.
2. Add one aggregate enable input in the source-of-truth vars location for
   that layer.
3. Add or update one role-scoped vars file in examples (`<role>.yml`).
4. Keep docs generic and link to source-of-truth files instead of listing every child role by name.

## Tag Usage

Use generic phase tags during development:

```bash
ansible-playbook ... --tags assert
ansible-playbook ... --tags install
ansible-playbook ... --tags config
ansible-playbook ... --tags validate
```

Use role-specific tags for narrower runs through aggregate stacks.
If child-role tags change, update aggregate include-task tags in the same change so targeted execution remains predictable.

## Toggle Naming Convention

- Use `base_<role>_enabled` when a child role belongs to `base`.
- Use `user_include_<role>` when a child role is optional in `user`.
- Use `docker_include_<role>` when a child role is optional in `docker`.
- Use `backup_include_<role>` when a child role is optional in `backup`.
- Use `monitoring_include_<role>` when a child role is optional in
  `monitoring`.
- Keep legacy `base_include_*` values only as aggregate compatibility fallbacks
  while existing inventories migrate.
