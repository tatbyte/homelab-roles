# roles/monitoring_storage_health_now/README.md

Reference for the `monitoring_storage_health_now` role.
Explains how this validation-oriented companion role forces the managed
`monitoring-storage-health.service` oneshot unit to run immediately and then
inspects the resulting JSON.

## Purpose
- Reuse the already managed recurring storage-health service instead of duplicating check logic
- Trigger an immediate storage-health run for testing or operator-driven validation
- Read and assert the machine-readable JSON result written by `monitoring_storage_health`

## Notes
- Apply `monitoring_storage_health` first. This role expects the managed service unit and script to already exist.
- This role is reusable, but intentionally opt-in. It is meant for explicit operational runs, not automatic steady-state execution.
- The default allowed statuses are `ok` and `warn`, so non-critical warnings can still pass a manual validation run.

## Usage

```yaml
- name: Run storage health now for validation
  hosts: monitoring
  become: true
  roles:
    - role: monitoring_storage_health_now
```

## Dependencies
None

## License
MIT
