# roles/monitoring_docker_tag_now/README.md

Reference for the `monitoring_docker_tag_now` role.
Explains how this validation-oriented companion role forces the managed
`monitoring-docker-tag.service` oneshot unit to run immediately and then
inspects the JSON output.

## Purpose
- Reuse the already managed recurring Docker tag check instead of duplicating registry logic
- Trigger an immediate monitoring run for testing or operator-driven validation
- Read and assert the machine-readable JSON result written by `monitoring_docker_tag`

## Notes
- Apply `monitoring_docker_tag` first. This role expects the managed service
  unit and script to already exist.
- The default allowed statuses are `ok` and `warn`, so a host with pending
  image updates still passes the manual validation run.

## Usage

```yaml
- name: Run Docker tag monitoring now for validation
  hosts: monitoring
  become: true
  roles:
    - role: monitoring_docker_tag_now
```

## Dependencies
None

## License
MIT
