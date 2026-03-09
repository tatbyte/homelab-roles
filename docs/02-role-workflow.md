# docs/02-role-workflow.md

Reference for the shared role lifecycle used in this repository.
Explains the standard phase order and how role task files are expected to map to that workflow.

1. `assert`
2. `install`
3. `config`
4. `validate`

> **Note:** Not all phases are required in every role. For example, some roles may not need an `install` phase if no packages or dependencies are installed. Include only the phases relevant to your role.

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

## Tag Usage

Run specific phases during development or troubleshooting:

```bash
ansible-playbook ... --tags assert
ansible-playbook ... --tags install
ansible-playbook ... --tags config
ansible-playbook ... --tags validate
```

Run the full workflow by running the playbook with no tag filter.
