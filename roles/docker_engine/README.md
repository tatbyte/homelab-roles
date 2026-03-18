# roles/docker_engine/README.md

Reference for the `docker_engine` role.
Explains how the role installs and validates Docker engine plus Docker supplementary-group access on Debian-family hosts.

## Features
- Installs requested Docker engine packages with APT
- Ensures the Docker service is enabled and running
- Ensures the Docker supplementary group exists
- Adds requested existing users to the Docker supplementary group
- Optionally registers Docker group memberships for the aggregate `user_groups` role
- Verifies package, service, and group-membership state after changes

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `docker_engine_enabled` | `true` | no | Enables Docker engine package/service/group management in this role |
| `docker_engine_packages` | `['docker.io']` | no | Docker engine package list installed with APT |
| `docker_engine_service_name` | `docker` | no | Docker service name to enable and start |
| `docker_engine_group_name` | `docker` | no | Supplementary group used for non-root Docker access |
| `docker_engine_manage_group_memberships` | `true` | no | Whether this role should add existing users to the Docker supplementary group |
| `docker_engine_group_members` | de-duplicated `bootstrap_user` / `user_account_name` list with `admin` fallback | no | Existing users that should receive Docker supplementary-group access when present; the default falls back safely for standalone use and removes duplicates |
| `docker_engine_register_user_groups_memberships` | `false` | no | Whether to append role-declared memberships into `user_groups_role_declared_memberships` |
| `docker_engine_user_group_memberships` | `[]` | no | Membership entries registered for `user_groups` when optional centralized group enforcement is desired |

## Usage

The aggregate `docker` role can include `docker_engine` when `docker_include_engine: true`.
Run the Docker layer after the user layer when you want direct Docker
supplementary-group access applied to both the automation account and the
managed human admin account in one pass.
When used standalone, the default member list falls back to `admin` for either
account variable if the related bootstrap or user role vars are not present.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - docker_engine
```

Example variables:

```yaml
docker_engine_enabled: true
docker_engine_packages:
  - docker.io
docker_engine_group_members:
  - "{{ bootstrap_user }}"
  - "{{ user_account_name }}"
```

## Dependencies
None

## License
MIT

## Author
Tatbyte
