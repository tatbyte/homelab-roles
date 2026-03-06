# base Role

This role provides foundational tasks and configurations for all hosts in the Ansible environment.

## Features
- Essential system setup
- Common configuration tasks
- Can be extended by other roles

## Usage
Include the `base` role in your playbook:

```yaml
- hosts: all
  roles:
    - base
```

## Variables
Define any required variables in your inventory or playbook. See `meta/main.yml` and `tasks/main.yml` for details.

## License
MIT

## Author
Tatbyte
