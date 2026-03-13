# roles/base_hosts/README.md

Reference for the `base_hosts` role.
Explains how the role manages inventory-driven and optional manual cluster host mappings in `/etc/hosts` on Debian-family hosts during the base phase.

## Features
- Validates the requested inventory group, optional manual entries, marker format, and host mapping inputs
- Uses inventory hostnames and `ansible_host` values to build cluster host mappings
- Supports extra manual host mappings for devices that are not managed as Ansible inventory hosts
- Manages entries through an Ansible-managed block instead of overwriting the full `/etc/hosts` file
- Verifies the managed `/etc/hosts` block after changes
- Keeps scope narrow by not managing DNS resolver configuration or network interfaces

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `base_hosts_inventory_group` | `all` | no | Inventory group used to build the managed `/etc/hosts` block from inventory hostnames and `ansible_host` values |
| `base_hosts_manual_entries` | `[]` | no | Optional extra host mappings added after inventory entries; each item must define `ip` and a non-empty `names` list |
| `base_hosts_block_marker` | `# {mark} ANSIBLE HOSTS` | no | Marker string used by `blockinfile`; must contain `{mark}` |

## Usage

The `base` role can include `base_hosts` when `base_include_hosts: true`.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - base_hosts
```

Example variables:

```yaml
base_include_hosts: true
base_hosts_inventory_group: all
base_hosts_manual_entries:
  - ip: 192.168.0.10
    names:
      - nas
      - files
base_hosts_block_marker: "# {mark} ANSIBLE HOSTS"
```

This role is intentionally separate from `base_hostname` and `base_dns`.
Use `base_hostname` to manage the local system hostname, and use `base_hosts` when you want inventory-driven peer mappings plus optional manual entries in `/etc/hosts`.

## Dependencies
None

## License
MIT

## Author
Tatbyte
