# docs/06-user-groups-role-integration.md

Reference for supplementary-group integration from future application or service roles.
Explains how roles should register human admin supplementary-group needs for `user_groups` to aggregate and enforce centrally.

## Purpose

This repository keeps human admin supplementary-group enforcement centralized in
`user_groups`.
Application or service roles should declare their group needs and append them to
`user_groups_role_declared_memberships` instead of editing
`user_groups_additional_memberships` manually in inventory.

That gives you:

- automatic user-to-group access when a role is enabled
- one place where effective supplementary-group state is enforced
- inventory-specific overrides that can still be appended separately

## Aggregation Order

`user_groups` builds its effective pre-normalized membership list from:

1. `user_groups_base_memberships`
2. `user_groups_role_declared_memberships`
3. `user_groups_additional_memberships`

Then it merges entries for the same user into one effective membership
definition.

This means:

- shared baseline memberships stay first
- memberships from enabled roles are added next
- explicit inventory overrides or one-off additions can still be appended last

## Merge Behavior

When multiple entries target the same user, `user_groups`:

1. adds requested `groups` uniquely while entries stay additive
2. resets the effective user entry to exactly that entry's `groups` when a
   later entry sets `append: false`
3. continues from that reset point for any later entries for the same user

This keeps additive role declarations simple while still allowing inventory to
take explicit ownership when needed.

Unlike `base_firewall`, `user_groups` does not keep a separate live-state
registry for automatic stale-membership cleanup.
If a future role stops declaring an additive membership, that group is only
removed when some later effective input for the same user takes explicit
ownership with `append: false`.

## How A Role Registers Group Memberships

Keep role-specific supplementary-group needs in that role's defaults or vars.
Then append them with `set_fact` only when the role is enabled.

Example defaults:

```yaml
docker_engine_user_group_memberships:
  - user: "{{ user_account_name }}"
    groups:
      - docker
    append: true
```

Example task:

```yaml
- name: "Config | Register user supplementary groups"
  ansible.builtin.set_fact:
    user_groups_role_declared_memberships: >-
      {{
        (user_groups_role_declared_memberships | default([]))
        + (docker_engine_user_group_memberships | default([]))
      }}
  when: docker_engine_enabled | default(false)
```

## Ordering Requirement

The registration task must run before `user_groups` enforces supplementary-group
state.

If a future application role lives outside that aggregate order, either:

- run that role earlier in the same play before `user_groups`
- or run `user_groups` in a later play after the role has registered its
  memberships

Use `roles/user/tasks/main.yml` as the source of truth for current aggregate
ordering instead of maintaining role-by-role order copies in docs.

## When To Use Additional Memberships Instead

Use `user_groups_additional_memberships` when a membership is:

- inventory-specific rather than owned by one role
- intentionally manual
- not tied to a role enable or disable toggle

Use `user_groups_role_declared_memberships` when a membership belongs to a role
and should be added while that role is enabled.
Use a later `append: false` inventory entry when you need exact final
supplementary-group ownership for that user.
