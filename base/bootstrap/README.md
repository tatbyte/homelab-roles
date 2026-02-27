# Bootstrap Role

This role bootstraps a host by creating an admin user and configuring SSH access.

## Purpose
- Creates an admin user with specified username, UID, GID, and shell
- Adds the main authorized SSH key for the admin user
- Validates required variables, user creation, shell, and group membership

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `bootstrap_user` | `admin` | yes | Admin username |
| `bootstrap_puid` | `1000` | yes | UID for admin user (must be >= 1000) |
| `bootstrap_pgid` | `1000` | yes | GID for admin user (must be >= 1000) |
| `user_shell` | `/bin/bash` | yes | Shell for admin user (absolute path) |
| `bootstrap_authorized_key` | `""` | no | SSH public key to add to admin user |

## Usage

```yaml
- hosts: all
  roles:
    - base/bootstrap
```

## Dependencies
None

## Author
tatbyte

## License
MIT
