# docs/04-firewall-role-integration.md

Reference for firewall rule integration from future application or service roles.
Explains how roles should register UFW rules for `base_firewall` to aggregate and clean up automatically.

## Purpose

This repository keeps firewall enforcement centralized in `base_firewall`.
Application or service roles should declare their firewall needs and append them
to `base_firewall_role_declared_rules` instead of editing
`base_firewall_additional_rules` manually in inventory.

That gives you:

- automatic port opens when a role is enabled
- automatic stale-rule removal when a role stops declaring a managed rule
- one place where UFW state is ultimately enforced

## Aggregation Order

`base_firewall` builds the effective rule list from:

1. `base_firewall_base_rules`
2. `base_firewall_role_declared_rules`
3. `base_firewall_additional_rules`

This means:

- shared baseline rules stay first
- rules from enabled roles are added next
- explicit inventory overrides or one-off additions can still be appended last

## Managed Comment Convention

Rules registered by other roles must set a `comment` that starts with
`base_firewall_managed_comment_prefix`, which defaults to `managed:`.

Example:

```yaml
comment: "managed:docker_traefik:dashboard"
```

`base_firewall` uses that prefix to distinguish role-owned rules from manual
UFW rules. In additive mode, only managed-prefixed live rules are candidates
for automatic stale cleanup.

Manual rules without that prefix are left alone unless
`base_firewall_purge_unmanaged_rules: true`.

## How A Role Registers Rules

Keep role-specific firewall rules in that role's defaults or vars.
Then append them with `set_fact` only when the role is enabled.

Example defaults:

```yaml
docker_traefik_firewall_rules:
  - rule: allow
    direction: in
    port: "8080"
    proto: tcp
    comment: "managed:docker_traefik:dashboard"
```

Example task:

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

## Ordering Requirement

The registration task must run before `base_firewall` enforces UFW state.

Inside the aggregate `base` role, `base_firewall` runs after:

1. `base_packages`
2. `base_locale`
3. `base_timezone`
4. `base_ntp`
5. `base_hostname`
6. optional `base_hosts`
7. optional `base_dns`
8. `base_sudo`
9. `base_sshd`

If a future application role lives outside that aggregate order, either:

- run that role earlier in the same play before `base_firewall`
- or run `base_firewall` in a later play after the role has registered rules

## Stale Rule Cleanup

In additive mode, `base_firewall`:

1. reads `ufw show added`
2. finds live rules whose comment starts with the managed prefix
3. compares them with the currently desired managed rules
4. deletes managed rules that are no longer declared
5. ensures the full desired rule list exists

This is what closes ports automatically after a role is disabled.

## When To Use Additional Rules Instead

Use `base_firewall_additional_rules` when a rule is:

- inventory-specific rather than owned by one role
- intentionally manual
- not tied to a role enable or disable toggle

Use `base_firewall_role_declared_rules` when a rule belongs to a role and
should appear or disappear with that role.
