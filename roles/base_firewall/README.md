# roles/base_firewall/README.md

Reference for the `base_firewall` role.
Explains how the role manages a UFW baseline on Debian-family hosts during the base phase.

## Features
- Installs the UFW package with APT before firewall configuration
- Validates the requested package, state, logging, default-policy, and rule inputs
- Refuses to enable a deny-or-reject incoming firewall baseline unless the managed rules still allow SSH or Ansible access on the management port
- Configures UFW logging plus default incoming and outgoing policies
- Ensures the requested UFW rules exist without resetting the firewall by default
- Can optionally purge unmanaged UFW rules by resetting and rebuilding the managed ruleset
- Enables or disables UFW according to the role input
- Verifies effective firewall status, the stored desired-state checksum, and the stored added-rule commands after changes

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_firewall_packages` | `['ufw']` | no | Package list installed with APT to provide the firewall |
| `base_firewall_enabled` | `true` | no | Whether UFW is enabled after the role applies |
| `base_firewall_logging` | `low` | no | UFW logging level; supported values are `off`, `on`, `low`, `medium`, `high`, and `full` |
| `base_firewall_default_incoming_policy` | `deny` | no | Default UFW policy for incoming traffic |
| `base_firewall_default_outgoing_policy` | `allow` | no | Default UFW policy for outgoing traffic |
| `base_firewall_purge_unmanaged_rules` | `false` | no | When `true`, reset UFW and rebuild only the managed rules when the current added-rule list no longer matches `base_firewall_rules` |
| `base_firewall_state_checksum_path` | `/etc/ufw/.base_firewall_state.sha256` | no | Path used to store the checksum of the requested managed firewall state after configuration |
| `base_firewall_base_rules` | SSH rate-limit rule on `base_sshd_port` | no | Baseline rules managed by the role for every host |
| `base_firewall_additional_rules` | `[]` | no | Extra per-host or per-group firewall rules appended to the baseline, such as a Traefik dashboard allow rule |
| `base_firewall_rules` | `base_firewall_base_rules + base_firewall_additional_rules` | no | Effective ordered list of UFW rules to ensure are present; supported keys are `rule`, `direction`, `port`, `proto`, `from_ip`, `to_ip`, `comment`, and `log` |

## Usage

The `base` role can include `base_firewall` when `base_include_firewall: true`.

Usage through the aggregate `base` role:

```yaml
- hosts: all
  become: true
  vars:
    base_include_firewall: true
  roles:
    - base

- hosts: all
  become: true
  roles:
    - base_firewall
```

Example variables:

```yaml
base_include_firewall: true
base_firewall_default_incoming_policy: deny
base_firewall_default_outgoing_policy: allow
base_firewall_purge_unmanaged_rules: false
base_firewall_additional_rules:
  - rule: allow
    direction: in
    port: "8080"
    proto: tcp
    from_ip: 192.168.1.0/24
    comment: Allow Traefik dashboard from LAN
```

This role applies an additive firewall baseline by default, so it ensures the requested rules exist while leaving unrelated or manually added UFW rules in place.
Set `base_firewall_purge_unmanaged_rules: true` when you want the role to reset UFW and rebuild only the managed rules from `base_firewall_rules`.
Use `base_firewall_base_rules` for the shared baseline and `base_firewall_additional_rules` for host-specific additions such as a Traefik dashboard port on only one host.
If you set `base_firewall_default_incoming_policy` to `deny` or `reject`, keep at least one incoming `allow` or `limit` rule for the SSH or Ansible management port in the effective `base_firewall_rules` list or the role will fail early.
Keep `base_firewall_rules` ordered for readability and stable `ufw show added` output.
Rule directions use `in` and `out` so the stored commands match the long-form syntax used by the Ansible UFW module.

## Dependencies
None

## License
MIT

## Author
Tatbyte
