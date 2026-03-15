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

## How To Use It

Create or edit an encrypted vars file:

```sh
ansible-vault create inventory/group_vars/all/vault.yml
ansible-vault edit inventory/group_vars/all/vault.yml
```

Then store secret values there and reference them from normal vars files:

```yaml
# inventory/group_vars/all/vault.yml
vault_user_password_hash: "$6$..."
```

```yaml
# inventory/group_vars/all/user_password.yml
user_password_password_hash: "{{ vault_user_password_hash }}"
```

## Which Roles Use Vault Well

- `user_password`: best current fit, because it manages `user_password_password_hash`, which is secret-bearing and should not live in plain inventory.

Today, `user_account`, `user_groups`, `base_*`, and `monitoring_authorized_key` do not need Vault for their normal role inputs.
The example `bootstrap` flow also prompts for the initial password instead of storing it in inventory.

## Why

Use Vault when a variable is secret-bearing, reusable, and should stay out of normal tracked YAML.
For this repository today, that mainly means local password hashes managed by `user_password`.
