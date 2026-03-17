# docs/05-vault.md

Short Vault guidance for this repository.
Explains where to keep a local Vault password file, how to point Ansible at it, and which current role inputs are the right fit for Vault.

## Recommended Local Path

Keep your personal Ansible config and Vault password file under:

- `~/.config/ansible/ansible.cfg`
- `~/.config/ansible/vault/password.txt`

Suggested permissions:

- `~/.config/ansible/`: `0700`
- `~/.config/ansible/vault/password.txt`: `0600`

Example:

```sh
mkdir -p ~/.config/ansible/vault
chmod 700 ~/.config/ansible ~/.config/ansible/vault
printf '%s\n' 'your-vault-password' > ~/.config/ansible/vault/password.txt
chmod 600 ~/.config/ansible/vault/password.txt
```

## Ansible Config

Point Ansible at that file from `~/.config/ansible/ansible.cfg`:

```ini
[defaults]
vault_password_file = ~/.config/ansible/vault/password.txt
```

The example lab also sets this directly in `examples/ansible.cfg`, so the
example playbooks intentionally expect that file to exist at the standard local
path.

## How To Use It

Create or edit an encrypted vars file:

```sh
ansible-vault create inventory/group_vars/all/vault.yml
ansible-vault edit inventory/group_vars/all/vault.yml
```

Keep only the real encrypted file in `group_vars/all/`.
Do not keep example files in that directory, because Ansible loads every file
it finds there.
Store any checked-in example outside `group_vars/all/`, for example at
`inventory/examples/vault.yml.example`.

Because the example `ansible.cfg` points at `~/.config/ansible/vault/password.txt`,
create that file before running the example playbooks.

Then store secret values there and reference them from normal vars files:

```yaml
# inventory/group_vars/all/vault.yml
vault_user_password_hash: "$6$..."
vault_bootstrap_login_password: "..."
```

```yaml
# inventory/group_vars/all/user_password.yml
user_password_password_hash: "{{ vault_user_password_hash }}"
```

```yaml
# inventory/group_vars/all/bootstrap.yml
bootstrap_login_user: "admin"
bootstrap_login_password: "{{ vault_bootstrap_login_password }}"
```

## How `bootstrap.yml` And `vault.yml` Work Together

Ansible loads both `bootstrap.yml` and `vault.yml` from `group_vars/all/` and
merges them into the same variable set for the play.

Use this split:

- `bootstrap.yml`: non-secret role inputs and references to secret vars
- `vault.yml`: raw secret values only

Example:

```yaml
# inventory/group_vars/all/bootstrap.yml
bootstrap_login_user: "admin"
bootstrap_login_password: "{{ vault_bootstrap_login_password }}"
```

```yaml
# inventory/group_vars/all/vault.yml
vault_bootstrap_login_password: "admin"
```

Do not rely on file order between these files.
Also make sure `vault.yml` contains YAML, not shell or INI syntax, and keep
fallback logic in normal vars files rather than inside Vault data.

Correct:

```yaml
vault_bootstrap_login_password: "admin"
```

Incorrect:

```text
vault_bootstrap_login_password=admin
```

## Which Roles Use Vault Well

- Any role input that carries secret-bearing values (password hashes, private
  keys, API tokens, or credentials) is a good Vault candidate.
- In this repository today, the most common example is hashed password input
  for user management.
- Treat role names here as examples, not a fixed list, so new secret-bearing
  roles can adopt Vault without needing this doc rewritten.

## Why

Use Vault when a variable is secret-bearing, reusable, and should stay out of normal tracked YAML.
For this repository today, that mainly means local password hashes and
bootstrap login credentials used by the example harness.
