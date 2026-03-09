# roles/base/README.md

Reference for the `base` role.
Explains how the aggregate base role delegates recurring Debian-family host configuration through role dependencies.

## Features
- Runs the recurring base configuration on every `base` execution
- Keeps orchestration in `roles/base/meta/main.yml`
- Includes `base_packages`, `base_locale`, `base_ntp`, and `base_timezone` through role dependencies

## Usage
Use `base` on Debian-family hosts after the bootstrap phase has already created the automation account:

```yaml
- hosts: all
  become: true
  roles:
    - base
```

Bootstrap is handled separately by the standalone `bootstrap` role/playbook.
Role-specific inputs for `base` currently come from `base_packages_*`, `base_locale_*`, `base_ntp_*`, and `base_timezone_*`.

## License
MIT

## Author
Tatbyte
