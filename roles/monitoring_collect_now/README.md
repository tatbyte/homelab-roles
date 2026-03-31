# roles/monitoring_collect_now/README.md

Reference for the `monitoring_collect_now` role.
Triggers the recurring collector oneshot service immediately and validates the
resulting aggregated `index.json` without changing the recurring timer.

## Purpose
- Force the collector to run on demand for testing
- Confirm the aggregated output file refreshed
- Print a compact summary of the collected host statuses

## Dependencies
- `monitoring_collect` must already be applied on the target host

## License
MIT
