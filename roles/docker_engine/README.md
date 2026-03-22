# roles/docker_engine/README.md

Reference for the `docker_engine` role.
Explains how the role installs and validates Docker engine plus daemon defaults and Docker supplementary-group access on Debian-family hosts.

## Features
- Installs requested Docker engine packages with APT
- Optionally removes conflicting Docker Inc. packages first when converging to the distro `docker.io` package family
- Renders `/etc/docker/daemon.json` from role-managed inputs
- Applies default Docker log-driver and log-rotation settings for all containers
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
| `docker_engine_cleanup_conflicting_packages` | `{{ 'docker.io' in docker_engine_packages }}` | no | When true, purge known conflicting Docker Inc. packages before installing the requested engine packages |
| `docker_engine_conflicting_packages` | `['containerd.io', 'docker-ce', 'docker-ce-cli', 'docker-ce-rootless-extras', 'docker-buildx-plugin', 'docker-compose-plugin']` | no | Package names removed first when the role cleans up conflicting Docker Inc. packages |
| `docker_engine_fix_broken_apt_after_cleanup` | `true` | no | Whether to run `apt` in `fixed` mode after conflicting-package cleanup before installing the requested engine packages |
| `docker_engine_service_name` | `docker` | no | Docker service name to enable and start |
| `docker_engine_group_name` | `docker` | no | Supplementary group used for non-root Docker access |
| `docker_engine_daemon_config_path` | `/etc/docker/daemon.json` | no | Path of the managed Docker daemon configuration file |
| `docker_engine_log_driver` | `json-file` | no | Default Docker log driver applied through the daemon |
| `docker_engine_log_opts` | `{'max-size': '10m', 'max-file': '3'}` | no | Default Docker log rotation options applied through the daemon |
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
docker_engine_cleanup_conflicting_packages: true
docker_engine_log_driver: json-file
docker_engine_log_opts:
  max-size: "10m"
  max-file: "3"
docker_engine_group_members: >-
  {{
    [
      bootstrap_user,
      user_account_name
    ]
    | map('trim')
    | reject('equalto', '')
    | unique
    | list
  }}
```

## Package Family Rule

Keep one Docker package family per host.
If a host uses distro Docker packages such as `docker.io`, keep the related
Compose support in the distro family too.
Do not mix that with Docker Inc. packages such as `docker-ce`,
`containerd.io`, `docker-buildx-plugin`, or `docker-compose-plugin` unless the
host is intentionally managed as a Docker Inc. package host.

This role defaults to the distro `docker.io` family and can purge the known
Docker Inc. conflicts before install so migrations converge cleanly.
Future Docker application roles should follow the same rule and avoid assuming
that every host uses the same package family.

## Dependencies
None

## License
MIT

## Author
Tatbyte
