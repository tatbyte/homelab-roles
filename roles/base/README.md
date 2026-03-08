# base Role

Aggregate foundation role for all hosts.

## Features
- Conditionally runs `base_bootstrap` during bootstrap phase
- Runs `base_packages` during normal phase
- Keeps phase switching centralized in `roles/base/meta/main.yml`

## Usage
Use `base` in both plays, and switch behavior with `base_run_bootstrap`:

```yaml
- hosts: bootstrap
  vars:
    base_run_bootstrap: true
  roles:
    - base

- hosts: all
  vars:
    base_run_bootstrap: false
  roles:
    - base
```

## Variables
- `base_run_bootstrap` (bool, default `false`)
  - `true`: execute `base_bootstrap` dependency
  - `false`: execute `base_packages` dependency

Role-specific inputs still come from each dependency role (`base_bootstrap_*`, `base_packages_*`).

## License
MIT

## Author
Tatbyte
