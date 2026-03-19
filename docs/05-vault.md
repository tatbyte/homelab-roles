# docs/05-vault.md

Short Vault guidance for this repository.
Explains where to keep a local Vault password file, how to point Ansible at it, and which current role inputs are the right fit for Vault.

## Recommended Local Path

Keep your personal Ansible config and Vault password file under:

- `~/.config/ansible/ansible.cfg`
- `~/.config/ansible/vault.pass`
- `~/.config/ansible/vault.yml`

Suggested permissions:

- `~/.config/ansible/`: `0700`
- `~/.config/ansible/vault.pass`: `0600`
- `~/.config/ansible/vault.yml`: `0600`

Example:

```sh
mkdir -p ~/.config/ansible
chmod 700 ~/.config/ansible
printf '%s\n' 'your-vault-password' > ~/.config/ansible/vault.pass
chmod 600 ~/.config/ansible/vault.pass
ansible-vault create ~/.config/ansible/vault.yml
```

## Ansible Config

Point Ansible at that file from `~/.config/ansible/ansible.cfg`:

```ini
[defaults]
vault_password_file = ~/.config/ansible/vault.pass
```

The example lab also sets this directly in `examples/ansible.cfg`, so the
example playbooks intentionally expect that file to exist at the standard local
path.

## How To Use It

Create or edit an encrypted vars file:

```sh
ansible-vault create ~/.config/ansible/vault.yml
ansible-vault edit ~/.config/ansible/vault.yml
```

Keep the real encrypted secret file outside the repo at
`~/.config/ansible/vault.yml`.
Do not keep checked-in example files in `group_vars/all/`, because Ansible
loads every file it finds there.
Store checked-in examples elsewhere, for example at
`inventory/examples/vault.yml.example`.

Because the example `ansible.cfg` points at `~/.config/ansible/vault.pass`,
create that file before running the example playbooks.

Then store secret values there and reference them from normal vars files:

```yaml
# ~/.config/ansible/vault.yml
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

## How `bootstrap.yml` And The Local Vault File Work Together

The example playbooks load non-secret role inputs from `group_vars/all/` and
load secret values from `~/.config/ansible/vault.yml` separately.

Use this split:

- `bootstrap.yml`: non-secret role inputs and references to secret vars
- `~/.config/ansible/vault.yml`: raw secret values only

Example:

```yaml
# inventory/group_vars/all/bootstrap.yml
bootstrap_login_user: "admin"
bootstrap_login_password: "{{ vault_bootstrap_login_password }}"
```

```yaml
# ~/.config/ansible/vault.yml
vault_bootstrap_login_password: "admin"
```

Also make sure `~/.config/ansible/vault.yml` contains YAML, not shell or INI
syntax, and keep fallback logic in normal vars files rather than inside Vault
data.

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
