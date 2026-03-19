# docs/07-docker-role-conventions.md

Reference for Docker-role conventions in this repository.
Defines the shared expectations for daemon defaults, role-owned identities, and backup-friendly host paths.

## Purpose

Docker roles in this repository follow a small set of conventions so host
rebuilds, backups, and access control stay predictable across services.

## Docker Engine

- Keep daemon-wide Docker defaults in `docker_engine`.
- Manage `/etc/docker/daemon.json` from role variables instead of editing it by
  hand on hosts.
- Put default log-driver and log-rotation settings there so all containers
  inherit bounded logging unless a service overrides them intentionally.

## Role-Owned Identities

- Keep runtime Docker socket access separate from feature access.
- `docker_engine` owns the generic `docker` supplementary group for Docker CLI
  access when needed.
- Service roles such as `docker_traefik` should create their own identities:
  - service user: `srv_<service>`
  - feature access group: `access_<service>`
- Add the automation user and managed human admin user to the feature access
  group when that role owns host-side files they should inspect or maintain.
- Avoid generic names such as `proxy` or `backup`; use role-owned names instead.

## Host Paths And Backups

- Keep Docker service projects under `/srv/<service>`.
- Keep persistent service data under `/srv/<service>/data`.
- Use bind mounts from that `data` path instead of hiding important state under
  `/var/lib/docker` when practical.
- This keeps Restic backup scope simple because `/srv` can be backed up and
  restored before Ansible re-applies the host configuration.

## Traefik-Managed Service Conventions

- Downstream service roles that publish HTTP or HTTPS through Traefik should
  join the stable external proxy network created by `docker_traefik`.
- Prefer Docker Compose labels for Traefik router and service metadata when the
  service only needs its own HTTP routing, instead of adding more file-provider
  config under the Traefik role.
- Keep the shared network name explicit in role vars so the service can follow
  the same proxy-network contract in both the example lab and consumer repos.
