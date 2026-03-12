# docs/02-role-workflow.md

Reference for the shared role lifecycle used in this repository.
Explains the standard phase order and how role task files are expected to map to that workflow in this Debian-family repository.

1. `assert`
2. `install`
3. `config`
4. `validate`

> **Note:** Not all phases are required in every role. For example, some roles may not need an `install` phase if no packages or dependencies are installed. Include only the phases relevant to your role.
> Repository roles currently target Debian-family hosts such as Debian and Ubuntu, so install and config tasks may assume APT and Debian-family file locations.

## Phase Purpose

- `assert`
Validate role inputs before changing system state.
Fail early when required variables or value formats are invalid.

- `install`
Install packages, dependencies, users, directories, or service units required by the role.
This phase prepares everything needed before configuration is applied.

- `config`
Apply desired configuration and enforce final state for managed resources.
Keep tasks idempotent so reruns are safe.

- `validate`
Verify the resulting state matches expectations after configuration.
Use explicit checks and assertions so failures are clear and actionable.

## Recommended Task Structure

Use one `tasks/main.yml` entrypoint that imports phase files in order.

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

## Compact Roles

Simple roles do not need many tasks per phase.

If a role manages one narrow piece of state, keep the phase structure but reduce output noise by:

- omitting unused phases such as `install`
- collecting facts in one task, then asserting them in one follow-up task
- combining related validation checks into a single `ansible.builtin.assert`
- keeping `tasks/main.yml` as the stable phase entrypoint

Use this compact style when it improves readability and reduces task noise without hiding important state changes.

## Aggregate Base Order

The aggregate `base` role in this repository applies its component roles in a stable order.
`roles/base/tasks/main.yml` is the single source of truth and uses explicit `ansible.builtin.include_role` entries for the aggregate sequence.
Its include-task tags should mirror the generic phase tags plus the child role's role-specific tags so both broad and narrow tagged runs behave predictably.

Current order:

1. `base_packages`
2. `base_locale`
3. `base_timezone`
4. `base_ntp`
5. `base_hostname`
6. `base_sudo`
7. `base_sshd`

Use this sequence to keep foundational packages and environment settings first, then time synchronization, then final host identity, sudo policy, and SSH daemon policy.

Optional current follow-up:

1. `base_firewall` when `base_include_firewall: true`
2. `base_logging` when `base_include_logging: true`
3. `base_updates` when `base_include_updates: true`
4. `base_apparmor` when `base_include_apparmor: true`

Future optional follow-up roles should also be included explicitly from `roles/base/tasks/main.yml` and gated only by aggregate include flags.

## Tag Usage

Run specific phases during development or troubleshooting:

```bash
ansible-playbook ... --tags assert
ansible-playbook ... --tags install
ansible-playbook ... --tags config
ansible-playbook ... --tags validate
```

For aggregate roles that use explicit `include_role` orchestration, tag the include tasks with the same generic phase tags and role-specific tags exposed by the child roles.
This keeps `--tags validate` working across the aggregate stack and also allows targeted runs such as `--tags base_packages_validate` without entering unrelated roles.
When you add a new aggregate child role or change a child role's tags, update the parent include-task tags to match so targeted execution keeps working as documented.

Run the full workflow by running the playbook with no tag filter.
