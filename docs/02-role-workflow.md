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

For aggregate roles such as `base`, `docker`, and `user`:

- Keep execution order explicit with `ansible.builtin.include_role` in `tasks/main.yml`.
- Keep required baseline roles first, then optional follow-up roles.
- Gate optional child roles with aggregate toggles (`base_include_*`, `user_include_*`).
- Keep include-task tags aligned with child role phase tags and role-specific tags.
- Treat aggregate `tasks/main.yml` as the source of truth for current order.

This avoids frequent documentation churn when new child roles are introduced.

## Adding A New Optional Child Role

1. Add an explicit `include_role` entry in the aggregate `tasks/main.yml`.
2. Add one aggregate toggle in aggregate defaults (`<aggregate>_include_<role>`).
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

- Use `base_include_<role>` when a child role is optional in `base`.
- Use `user_include_<role>` when a child role is optional in `user`.
- Use `<role>_enabled` only for installable services where disabled is a supported steady state.

Keep aggregate toggles separate from child-role behavior inputs.
