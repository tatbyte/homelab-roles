# roles/base_firewall/README.md

Reference for the `base_firewall` role.
Explains how the role manages a UFW baseline on Debian-family hosts during the base phase.

## Features
- Installs the UFW package with APT before firewall configuration
- Validates the requested package, state, logging, default-policy, and rule inputs
- Aggregates firewall rules from shared base rules, role-declared rules, and explicit additional rules
- Requires role-declared firewall rules to use a `managed:`-style comment prefix for traceable cleanup
- Refuses to enable a deny-or-reject incoming firewall baseline unless the managed rules still allow SSH or Ansible access on the management port
- Configures UFW logging plus default incoming and outgoing policies
- Persists UFW logging in `ufw.conf` so first runs and post-reset runs still converge while the firewall is inactive
- Ensures the requested UFW rules exist without resetting the firewall by default
- Removes stale UFW rules whose comments use the managed prefix when they are no longer declared
- Can optionally purge unmanaged UFW rules by resetting and rebuilding the managed ruleset
- Enables or disables UFW according to the role input
- Verifies effective firewall status, the stored desired-state checksum, and the stored added-rule commands after changes

## Repair Flow

Destructive backend repair work is intentionally kept out of this normal role.
Use the separate `base_firewall_repair` role through an ops playbook when a
host needs manual recovery from a masked UFW service, mixed
`iptables-legacy`/`iptables-nft` state, or broken UFW cached rule state.

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_firewall_packages` | `['ufw']` | no | Package list installed with APT to provide the firewall |
| `base_firewall_enabled` | `true` | no | Whether UFW is enabled after the role applies |
| `base_firewall_logging` | `low` | no | UFW logging level; supported values are `off`, `on`, `low`, `medium`, `high`, and `full` |
| `base_firewall_default_incoming_policy` | `deny` | no | Default UFW policy for incoming traffic |
| `base_firewall_default_outgoing_policy` | `allow` | no | Default UFW policy for outgoing traffic |
| `base_firewall_purge_unmanaged_rules` | `false` | no | When `true`, reset UFW and rebuild only the managed rules when the current added-rule list no longer matches `base_firewall_rules` |
| `base_firewall_remove_stale_managed_rules` | `false` | no | When `true`, remove live role-managed rules whose managed comments are no longer present in `base_firewall_rules` |
| `base_firewall_state_checksum_path` | `/etc/ufw/.base_firewall_state.sha256` | no | Path used to store the checksum of the requested managed firewall state after configuration |
| `base_firewall_managed_comment_prefix` | `managed:` | no | Comment prefix used to identify role-managed firewall rules that may be cleaned up automatically |
| `base_firewall_base_rules` | SSH rate-limit rule on `base_sshd_port` | no | Baseline rules managed by the role for every host |
| `base_firewall_role_declared_rules` | `[]` | no | Firewall rules accumulated from other roles before `base_firewall` runs; each item must set a `comment` that starts with `base_firewall_managed_comment_prefix` |
| `base_firewall_additional_rules` | `[]` | no | Extra per-host or per-group firewall rules appended to the baseline, such as a Traefik dashboard allow rule |
| `base_firewall_rules` | `base_firewall_base_rules + base_firewall_role_declared_rules + base_firewall_additional_rules` | no | Effective ordered list of UFW rules to ensure are present; supported keys are `rule`, `direction`, `port`, `proto`, `from_ip`, `to_ip`, `comment`, and `log` |

## Usage

The aggregate `base` role reads `base_firewall_enabled` from the role-scoped
base vars file.

Usage through the aggregate `base` role:

```yaml
- hosts: all
  become: true
  roles:
    - base

- hosts: all
  become: true
  roles:
    - base_firewall
```

Example variables:

```yaml
base_firewall_enabled: true
base_firewall_default_incoming_policy: deny
base_firewall_default_outgoing_policy: allow
base_firewall_purge_unmanaged_rules: false
base_firewall_remove_stale_managed_rules: false
base_firewall_role_declared_rules: []
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
Set `base_firewall_remove_stale_managed_rules: true` when you want additive mode to also delete live role-managed rules whose managed comments are no longer declared in the current effective ruleset.
Use `base_firewall_base_rules` for the shared baseline, `base_firewall_role_declared_rules` for rules registered by other enabled roles, and `base_firewall_additional_rules` for explicit host- or group-level additions.
If you set `base_firewall_default_incoming_policy` to `deny` or `reject`, keep at least one incoming `allow` or `limit` rule for the SSH or Ansible management port in the effective `base_firewall_rules` list or the role will fail early.
Keep `base_firewall_rules` ordered for readability and stable `ufw show added` output.
Rule directions use `in` and `out` so the stored commands match the long-form syntax used by the Ansible UFW module.
The role writes the requested logging level to `/etc/ufw/ufw.conf` before the final enabled or disabled state is enforced, so inactive or freshly reset hosts do not fail on `ufw logging <level>` while still converging to the requested runtime log level on the next enable or reload.
When additive mode is active, `base_firewall` only removes live UFW rules whose comments start with `base_firewall_managed_comment_prefix` when `base_firewall_remove_stale_managed_rules: true`.
Manual rules without that prefix are left untouched unless `base_firewall_purge_unmanaged_rules: true`.

## Role Integration

Roles that need ports opened should append their rules to `base_firewall_role_declared_rules` before `base_firewall` runs.
Use the managed comment prefix so `base_firewall` can tell role-owned rules apart from manual ones.

Example role task:

```yaml
- name: "Config | Register firewall rules"
  ansible.builtin.set_fact:
    base_firewall_role_declared_rules: >-
      {{
        (base_firewall_role_declared_rules | default([]))
        + (docker_traefik_firewall_rules | default([]))
      }}
  when: docker_traefik_enabled | default(false)
```

Example role defaults:

```yaml
docker_traefik_firewall_rules:
  - rule: allow
    direction: in
    port: "8080"
    proto: tcp
    comment: "managed:docker_traefik:dashboard"
```

If a role is later disabled and stops declaring that rule, `base_firewall` removes the stale managed rule automatically only when `base_firewall_remove_stale_managed_rules: true`.
If you rely on role-declared rules from roles outside the aggregate `base` stack, make sure those roles run earlier in the same play than `base_firewall`, or run `base_firewall` in a later play after they have registered their rules.
See [docs/04-firewall-role-integration.md](../../docs/04-firewall-role-integration.md) for a repository-level guide you can reuse when adding future app roles.

## Dependencies
None

## License
MIT

## Author
Tatbyte
