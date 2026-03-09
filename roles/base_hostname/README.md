# roles/base_hostname/README.md

Reference for the `base_hostname` role.
Explains how the role enforces the system hostname on Debian-family hosts during the base phase.

## Features
- Validates the requested hostname value before changes are applied
- Sets the current system hostname through the hostname module
- Writes `/etc/hostname` with the requested hostname or FQDN
- Verifies the managed file contents and the current short hostname after changes

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_hostname_name` | `localhost` | no | Hostname or FQDN written to `/etc/hostname`; validation expects the current short hostname to match the first label |

## Usage

The `base` role includes `base_hostname` through meta dependencies.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - base_hostname
```

Example variable:

```yaml
base_hostname_name: lab.example.internal
```

When `base_hostname_name` is an FQDN such as `lab.example.internal`, this role manages that full value in `/etc/hostname` and validates the current short hostname as `lab`.

## Dependencies
None

## License
MIT

## Author
Tatbyte
