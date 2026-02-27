# _common

This directory contains shared Ansible tasks and orchestrator logic for all roles in this repository.

## Purpose
- Provide a single, reusable task flow for all roles (assert → install → configure → validate)
- Reduce duplication and enforce best practices across roles

## Files
- `tasks/task_flow.yml`: The main orchestrator. Includes each phase (if present) in the correct order for any role that uses it.

## Usage
In your role's `tasks/main.yml`, include the task flow like this:

```yaml
- name: Execute task flow
  ansible.builtin.include_tasks: ../../../_common/tasks/task_flow.yml
  vars:
    _task_flow_phases:
      - assert
      - install
      - configure
      - validate
```

You can omit any phase your role does not need.

## Phases
- **assert**: Pre-flight checks (input validation)
- **install**: Optional installation steps
- **configure**: Main configuration logic
- **validate**: Post-flight checks (system state validation)

## Notes
- All roles should follow this pattern for consistency and maintainability.
- See other roles in this repository for examples.
