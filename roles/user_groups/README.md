# roles/user_groups/README.md

Reference for the `user_groups` role.
Explains how the role enforces supplementary group membership for existing human admin accounts after the base phase on Debian-family hosts in this repository.

## Features
- Validates a clear per-user supplementary-group inventory structure before making changes
- Requires target human admin accounts to already exist, typically from `user_account`
- Merges base, role-declared, and inventory-specific supplementary-group inputs into one effective per-user policy
- Supports append-versus-explicit supplementary-group behavior per managed user
- Can optionally create missing supplementary groups when that is intentional
- Validates the resulting effective supplementary-group state after configuration

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `user_groups_manage_groups` | `false` | no | If true, create requested supplementary groups before membership enforcement; if false, requested groups must already exist |
| `user_groups_base_memberships` | `[]` | no | Shared baseline supplementary-group membership definitions owned directly by `user_groups` |
| `user_groups_role_declared_memberships` | `[]` | no | Supplementary-group membership definitions registered by future roles before `user_groups` runs |
| `user_groups_additional_memberships` | `[]` | no | Inventory-specific supplementary-group membership definitions appended after the base and role-declared layers |
| `user_groups_memberships` | merged from the three lists above | no | Effective pre-normalized membership input used internally by the role before duplicate users are merged |

Each membership item in the three input lists above supports:

| Key | Default | Required | Description |
|-----|---------|----------|-------------|
| `user` | none | yes | Existing human admin username whose supplementary groups are managed |
| `groups` | none | yes | Desired supplementary groups for that user |
| `append` | `true` | no | If true, add the requested groups without removing unmanaged supplementary groups; if false, make supplementary-group membership explicit |

## Usage

Use `user_groups` after `user_account` or another earlier account-creation step has already ensured the target users exist:

```yaml
- hosts: all
  become: true
  roles:
    - role: user_account
    - role: user_groups
      vars:
        user_groups_memberships:
          - user: alice
            groups:
              - sudo
              - adm
              - systemd-journal
            append: true
```

Example aggregate-role usage:

```yaml
- hosts: all
  become: true
  vars:
    user_include_groups: true
    user_groups_memberships:
      - user: "{{ user_account_name }}"
        groups:
          - sudo
          - adm
        append: true
  roles:
    - role: user
```

Aggregation order inside `user_groups` is:

1. `user_groups_base_memberships`
2. `user_groups_role_declared_memberships`
3. `user_groups_additional_memberships`

Entries for the same user are merged into one effective membership definition.
Requested groups are combined uniquely per user while entries remain additive.
If a later entry for the same user sets `append: false`, it resets the
effective group list to exactly that entry's groups and takes explicit
ownership from that point forward.

Keep `append: true` when you want to add known admin groups without removing unrelated memberships created elsewhere.
Use `append: false` when you want this role to become the explicit owner of the user's full supplementary-group set, including the intentional empty-list case that removes all supplementary groups.
When `user_groups_manage_groups: false`, every requested group must already exist on the host before the role runs.
Future role declarations through `user_groups_role_declared_memberships` are additive by default; they do not get automatic stale-membership cleanup on their own the way `base_firewall` cleans up managed live rules.
Keep user-named primary-group ownership, such as the group that owns the home directory, in `user_account_primary_group`; `user_groups` only manages supplementary groups.

## Dependencies
None

## Author
tatbyte

## License
MIT
