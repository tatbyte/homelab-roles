# roles/base_sshd/README.md

Reference for the `base_sshd` role.
Explains how the role manages a Debian-family SSH daemon baseline during the base phase.

## Features
- Installs the OpenSSH server package with APT before SSH daemon configuration
- Validates the requested SSH package, service, port, login-policy, and user-list inputs
- Ensures the main `/etc/ssh/sshd_config` loads `/etc/ssh/sshd_config.d/*.conf` so the managed drop-in is effective
- Manages `/etc/ssh/sshd_config.d/90-base-sshd.conf` as a dedicated base-phase drop-in
- Validates SSH daemon syntax before the managed service is restarted
- Ensures the SSH service is enabled and running
- Verifies the managed drop-in contents and key effective SSH daemon settings after changes
- Validates general SSH daemon settings against baseline `sshd -T` output and checks `AllowUsers` in per-user `sshd -T -C` contexts

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_sshd_packages` | `['openssh-server']` | no | Package list installed with APT to provide the SSH daemon |
| `base_sshd_service_name` | `ssh` | no | Service name enabled, restarted, and validated by the role |
| `base_sshd_port` | `22` | no | TCP port enforced in the managed SSH daemon drop-in |
| `base_sshd_permit_root_login` | `no` | no | Root-login policy written to `PermitRootLogin`; allowed values are `yes`, `no`, `prohibit-password`, and `forced-commands-only` |
| `base_sshd_password_authentication` | `true` | no | Whether password authentication stays enabled in the managed SSH daemon drop-in |
| `base_sshd_pubkey_authentication` | `true` | no | Whether public-key authentication stays enabled in the managed SSH daemon drop-in |
| `base_sshd_allow_users` | `[]` | no | Optional login allow-list written to `AllowUsers`; when set, validation requires those users to be present in the effective `AllowUsers` result |
| `base_sshd_cleanup_bootstrap_handoff` | `true` | no | If true, remove the earlier bootstrap SSH handoff drop-in so the base SSH policy becomes the sole managed source of `AllowUsers` decisions |
| `base_sshd_bootstrap_handoff_config_path` | `/etc/ssh/sshd_config.d/80-bootstrap-access.conf` | no | Path of the bootstrap handoff drop-in removed when `base_sshd_cleanup_bootstrap_handoff` is enabled |

## Usage

The `base` role includes `base_sshd` through meta dependencies.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - base_sshd
```

Example variables:

```yaml
base_sshd_permit_root_login: "no"
base_sshd_password_authentication: false
base_sshd_pubkey_authentication: true
base_sshd_allow_users:
  - ansible
```

This role manages a dedicated drop-in under `/etc/ssh/sshd_config.d/` so Debian-family package defaults and other local drop-ins can stay separate from the base-phase policy.
It also ensures the main `/etc/ssh/sshd_config` contains `Include /etc/ssh/sshd_config.d/*.conf` near the top so the managed drop-in is actually loaded on hosts with older or hand-written SSH daemon configs.
By default it also removes the bootstrap handoff drop-in created by the
`bootstrap` role so the later base SSH policy can tighten `AllowUsers`
cleanly instead of inheriting the bootstrap-era allow-list forever.
If `base_sshd_allow_users` is empty, this role does not add an `AllowUsers` line of its own; any existing `AllowUsers` setting from other SSH daemon config files remains outside this role's management.
If `base_sshd_allow_users` is set, the role validates that those users are allowed after OpenSSH merges all config sources, but it does not require this role to be the only source of `AllowUsers` entries.
General validation for settings such as `Port`, `PermitRootLogin`, `PasswordAuthentication`, and `PubkeyAuthentication` uses baseline `sshd -T` output rather than trying to validate every external `Match` rule interaction on the host.

## Dependencies
None

## License
MIT

## Author
Tatbyte
