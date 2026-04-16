# docs/05-vault.md

Short Vault guidance for this repository.
Explains the inventory-local Vault layout used by the example lab.

## Password File

Keep the Vault password outside the repo:

```sh
mkdir -p ~/.config/ansible
chmod 700 ~/.config/ansible
printf '%s\n' 'your-vault-password' > ~/.config/ansible/vault.pass
chmod 600 ~/.config/ansible/vault.pass
```

`examples/ansible.cfg` points at that file and accepts `.vars` as a YAML
extension:

```ini
[defaults]
vault_password_file = ~/.config/ansible/vault.pass
yaml_valid_extensions = .yml, .yaml, .json, .vars
```

## File Pattern

Secret-bearing example inventory layers have tracked examples beside the vars
that consume them:

```text
examples/inventory/group_vars/bootstrap/vault.vars.example
examples/inventory/group_vars/user/vault.vars.example
examples/inventory/group_vars/docker/vault.vars.example
examples/inventory/group_vars/backup/vault.vars.example
examples/inventory/group_vars/monitoring/vault.vars.example
```

Copy only the keys you need into a same-directory `vault.vars`, then encrypt it:

```sh
cp examples/inventory/group_vars/docker/vault.vars.example examples/inventory/group_vars/docker/vault.vars
ANSIBLE_CONFIG=examples/ansible.cfg ansible-vault encrypt examples/inventory/group_vars/docker/vault.vars
ANSIBLE_CONFIG=examples/ansible.cfg ansible-vault edit examples/inventory/group_vars/docker/vault.vars
```

`vault.vars` is ignored by git. The `vault.vars.example` files stay tracked as
shape documentation.

## Current Uses

- `group_vars/bootstrap/vault.vars`: bootstrap login and sudo passwords
- `group_vars/user/vault.vars`: managed human-admin password hash
- `group_vars/docker/vault.vars`: ACME, DNS provider, dashboard auth, AdGuard,
  AdGuard Sync, and WireGuard setup secrets
- `group_vars/backup/vault.vars`: Restic repository, password, and S3 backend
  credentials
- `group_vars/monitoring/vault.vars`: collector SSH key material, monitoring
  dashboard auth, and ntfy URL
- `host_vars/<host>/vault.vars`: optional host-only secret overrides

Public Traefik hostnames are not Vault values. Keep values such as
`docker_traefik_dashboard_host`, `docker_adguard_host`,
`docker_adguard_sync_host`, and `docker_wireguard_host` in tracked inventory
vars.

## Notes

- Keep raw secret values in Vault and fallback logic in normal inventory vars.
- Do not add `vault_docker_public_domain_suffix`; service hostnames are
  explicit role variables now.
- Use host-local `vault.vars` only when a value truly differs for one host.
