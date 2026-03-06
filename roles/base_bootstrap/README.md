
# base_bootstrap Role

Bootstraps a host by creating and validating an admin user and SSH access.

## Features
- Creates admin user with custom username, UID, GID, and shell
- Adds authorized SSH key for admin user
- Validates variables, user creation, shell, and group membership

## Variables

| Variable                  | Default     | Required | Description                                 |
|---------------------------|-------------|----------|---------------------------------------------|
| `bootstrap_user`          | `admin`     | yes      | Admin username                              |
| `bootstrap_puid`          | `1000`      | yes      | UID for admin user (>= 1000)                |
| `bootstrap_pgid`          | `1000`      | yes      | GID for admin user (>= 1000)                |
| `user_shell`              | `/bin/bash` | yes      | Shell for admin user (absolute path)        |
| `bootstrap_authorized_key`| `""`       | no       | SSH public key to add to admin user         |

## Usage

Include the `base_bootstrap` role in your playbook:

```yaml
- hosts: all
  roles:
    - base_bootstrap
```

## Dependencies
None

## License
MIT

## Author
Tatbyte

## Author
tatbyte

## License
MIT
