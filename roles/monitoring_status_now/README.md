# roles/monitoring_status_now/README.md

Reference for the `monitoring_status_now` role.
Explains how this validation-oriented companion role forces the managed
`monitoring-status.service` oneshot unit to run immediately and then inspects
the unified JSON status output.

## Purpose
- Reuse the already managed recurring monitoring service instead of duplicating check logic
- Trigger an immediate monitoring run for testing or operator-driven validation
- Read and assert the machine-readable JSON result written by `monitoring_status`

## Notes
- Apply `monitoring_status` first. This role expects the managed service unit and script to already exist.
- This role is reusable, but intentionally opt-in. It is meant for explicit operational runs, not automatic steady-state execution.
- The default allowed statuses are `ok` and `warn`, so non-critical warnings can still pass a manual validation run.

## Usage

```yaml
- name: Run monitoring now for validation
  hosts: monitoring
  become: true
  roles:
    - role: monitoring_status_now
```

## Dependencies
None

## License
MIT
