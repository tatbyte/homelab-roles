# roles/base_firewall/README.md

Reference for the `base_firewall` role.
Explains how the role manages a UFW baseline on Debian-family hosts during the base phase.

## Features
- Installs the UFW package with APT before firewall configuration
- Validates the requested package, state, logging, default-policy, and rule inputs
- Refuses to enable a deny-or-reject incoming firewall baseline unless the managed rules still allow SSH or Ansible access on the management port
- Configures UFW logging plus default incoming and outgoing policies
- Resets and reapplies the managed UFW ruleset when the requested firewall state changes
- Enables or disables UFW according to the role input
- Verifies effective firewall status, the stored state checksum, and the stored added-rule commands after changes

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_firewall_packages` | `['ufw']` | no | Package list installed with APT to provide the firewall |
| `base_firewall_enabled` | `true` | no | Whether UFW is enabled after the role applies |
| `base_firewall_logging` | `low` | no | UFW logging level; supported values are `off`, `on`, `low`, `medium`, `high`, and `full` |
| `base_firewall_default_incoming_policy` | `deny` | no | Default UFW policy for incoming traffic |
| `base_firewall_default_outgoing_policy` | `allow` | no | Default UFW policy for outgoing traffic |
| `base_firewall_state_checksum_path` | `/etc/ufw/.base_firewall_state.sha256` | no | Path used to store the checksum of the requested managed firewall state so rule changes can be reapplied convergently |
| `base_firewall_rules` | SSH rate-limit rule on `base_sshd_port` | no | Ordered list of UFW rules to ensure are present; supported keys are `rule`, `direction`, `port`, `proto`, `from_ip`, `to_ip`, `comment`, and `log` |

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
base_firewall_rules:
  - rule: limit
    direction: in
    port: "{{ base_sshd_port | default(22) }}"
    proto: tcp
    comment: Limit SSH access
  - rule: allow
    direction: in
    port: "443"
    proto: tcp
    comment: Allow HTTPS
```

This role resets and reapplies the managed UFW state when the requested firewall variables change, so removed or changed managed rules do not linger from an older run.
If you set `base_firewall_default_incoming_policy` to `deny` or `reject`, keep at least one incoming `allow` or `limit` rule for the SSH or Ansible management port in `base_firewall_rules` or the role will fail early.
Set `comment: ""` on a managed rule when you want the role to clear an older stored UFW comment during the next convergent reapply.
Keep `base_firewall_rules` ordered for readability and stable `ufw show added` output.
Rule directions use `in` and `out` so the stored commands match the long-form syntax used by the Ansible UFW module.

## Dependencies
None

## License
MIT

## Author
Tatbyte
