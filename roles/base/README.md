# base Role

Aggregate foundation role for all hosts.

## Features
- Runs the recurring base configuration on every `base` execution
- Keeps orchestration in `roles/base/meta/main.yml`

## Usage
Use `base` after the bootstrap phase has already created the automation account:

```yaml
- hosts: all
  become: true
  roles:
    - base
```

Bootstrap is handled separately by the standalone `bootstrap` role/playbook.
Role-specific inputs for `base` currently come from `base_packages_*`.

## License
MIT

## Author
Tatbyte
