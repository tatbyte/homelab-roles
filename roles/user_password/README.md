# roles/user_password/README.md

Reference for the `user_password` role.
Explains how the role manages Vault-friendly local password state for one human admin account after the base phase on Debian-family hosts in this repository.

## Features
- Validates that the target human admin account already exists before password management starts
- Supports hashed password management without accepting plaintext passwords
- Supports optional password lock or unlock management separately from the password hash
- Keeps secret-bearing password behavior separate from the broader identity and filesystem scope of `user_account`
- Validates the resulting shadow-password state after configuration

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `user_password_user` | `{{ user_account_name | default('admin') }}` | yes | Human admin username whose password state is managed |
| `user_password_password_hash` | `null` | no | Vault-managed hashed password value; must begin with `$` when set |
| `user_password_password_lock` | `null` | no | Optional password-lock state: `true` locks, `false` unlocks, `null` leaves lock state unchanged |

At least one of `user_password_password_hash` or `user_password_password_lock` must be set when this role is enabled.

## Usage

Use `user_password` after `user_account` has already ensured the user exists:

```yaml
- hosts: all
  become: true
  vars:
    user_password_user: alice
    user_password_password_hash: "{{ vault_user_password_hash }}"
  roles:
    - role: user_account
    - role: user_password
```

Example aggregate-role usage:

```yaml
- hosts: all
  become: true
  vars:
    user_include_password: true
    user_password_password_hash: "{{ vault_user_password_hash }}"
  roles:
    - role: user
```

Store real password hashes in Ansible Vault or another secret backend.
Do not place plaintext passwords or real password hashes in repository defaults or non-secret inventory files.
The local `examples/` lab is the one exception in this repository: it uses a documented demo hash for the plaintext test password `password` so the user layer can be validated end to end.

## Dependencies
None

## Author
tatbyte

## License
MIT
