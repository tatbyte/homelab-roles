# docs/05-vault.md

Short Vault guidance for this repository.
Explains where to keep a local Vault password file, how to point Ansible at it, and which current role inputs are the right fit for Vault.

## Recommended Local Path

Keep your personal Ansible config and Vault password file under:

- `~/.config/ansible/ansible.cfg`
- `~/.config/ansible/vault.pass`
- `~/.config/ansible/lab_vault.yml`

Suggested permissions:

- `~/.config/ansible/`: `0700`
- `~/.config/ansible/vault.pass`: `0600`
- `~/.config/ansible/lab_vault.yml`: `0600`

Example:

```sh
mkdir -p ~/.config/ansible
chmod 700 ~/.config/ansible
printf '%s\n' 'your-vault-password' > ~/.config/ansible/vault.pass
chmod 600 ~/.config/ansible/vault.pass
ansible-vault create ~/.config/ansible/lab_vault.yml
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
That default behavior is controlled by
`examples/inventory/group_vars/all/secret_sources.yml`.

## How To Use It

Create or edit an encrypted vars file:

```sh
ansible-vault create ~/.config/ansible/lab_vault.yml
ansible-vault edit ~/.config/ansible/lab_vault.yml
```

Keep the real encrypted secret file outside the repo at
`~/.config/ansible/lab_vault.yml`.
Do not keep checked-in example files in `group_vars/all/`, because Ansible
loads every file it finds there.
Store checked-in examples elsewhere, for example at
`inventory/examples/vault.yml.example`.

Because the example `ansible.cfg` points at `~/.config/ansible/vault.pass`,
create that file before running the example playbooks.

Then store secret values there and reference them from normal vars files:

```yaml
# ~/.config/ansible/lab_vault.yml
vault_user_password_hash: "$6$..."
vault_bootstrap_login_password: "..."
```

```yaml
# inventory/group_vars/user/user_password.yml
user_password_password_hash: "{{ vault_user_password_hash }}"
```

```yaml
# inventory/group_vars/bootstrap/bootstrap.yml
bootstrap_login_user: "admin"
bootstrap_login_password: "{{ vault_bootstrap_login_password }}"
```

## How `bootstrap.yml` And The Local Vault File Work Together

The example playbooks load non-secret role inputs from inventory-managed
`group_vars/` files and load secret values from `~/.config/ansible/lab_vault.yml`
separately.

Use this split:

- `bootstrap.yml`: non-secret role inputs and references to secret vars
- `~/.config/ansible/lab_vault.yml`: raw secret values only

Example:

```yaml
# inventory/group_vars/bootstrap/bootstrap.yml
bootstrap_login_user: "admin"
bootstrap_login_password: "{{ vault_bootstrap_login_password }}"
```

```yaml
# ~/.config/ansible/lab_vault.yml
vault_bootstrap_login_password: "admin"
```

Also make sure `~/.config/ansible/lab_vault.yml` contains YAML, not shell or INI
syntax, and keep fallback logic in normal vars files rather than inside Vault
data.

## Shared Secret Source Switch

The example inventory includes a shared secret-source selector at:

```yaml
examples/inventory/group_vars/all/secret_sources.yml
```

It controls whether example playbooks load the controller-local Vault file:

```yaml
secret_sources_use_local_vault_file: true
secret_sources_local_vault_file: "{{ lookup('env', 'HOME') }}/.config/ansible/lab_vault.yml"
```

- `true`: keep the default example behavior and load the local Vault file.
- `false`: skip the controller-local file and rely on inventory-backed vars
  instead.

For future example playbooks, prefer this pattern:

1. Read the shared `secret_sources_*` vars from `group_vars/all/`.
2. Load the local file only when the switch is enabled.
3. Load it from delegated `pre_tasks` inside the target play rather than from
   a separate `hosts: localhost` pre-play, so `--limit <host>` runs still load
   the local Vault values.
4. Override canonical inventory vars such as `bootstrap_login_password`
   instead of introducing playbook-only secret variable names.

Correct:

```yaml
vault_bootstrap_login_password: "admin"
```

Incorrect:

```text
vault_bootstrap_login_password=admin
```

## Docker URL Pattern

The example Docker inventory no longer keeps full Traefik or AdGuard host
names in Vault.

Instead, the example derives those URLs from:

- the inventory `alias` host var when present, with `inventory_hostname` as a fallback
- `vault_docker_public_domain_suffix` from `~/.config/ansible/lab_vault.yml`

Example result for a host with `alias=lab`:

```yaml
docker_traefik_dashboard_host: "traefik.lab.example.com"
docker_adguard_host: "adguard.lab.example.com"
```

Keep the supporting DNS records or rewrite rules aligned with that pattern so
those derived hostnames resolve correctly.

## Which Roles Use Vault Well

- Any role input that carries secret-bearing values (password hashes, private
  keys, API tokens, or credentials) is a good Vault candidate.
- In this repository today, the most common example is hashed password input
  for user management.
- For the example Docker roles, keep API tokens, basic-auth users, and admin
  password hashes in Vault. The shared dashboard domain suffix also lives in
  Vault, while the final Traefik and AdGuard hostnames stay derived in normal
  vars files from `alias`.
- For `adguardhome-sync`, keep the sync UI host, direct AdGuard LAN IPs or
  URLs, and plaintext API passwords in Vault-backed vars because the sync tool
  needs live login input rather than the bcrypt hash used by AdGuard Home
  itself.
- Treat role names here as examples, not a fixed list, so new secret-bearing
  roles can adopt Vault without needing this doc rewritten.

## Why

Use Vault when a variable is secret-bearing, reusable, and should stay out of normal tracked YAML.
For this repository today, that mainly means local password hashes and
bootstrap login credentials used by the example harness.
