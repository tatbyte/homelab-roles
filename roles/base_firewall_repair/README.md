# roles/base_firewall_repair

Manual repair helper for UFW lockouts and iptables backend drift.

This role is intentionally separate from `base_firewall`. Normal firewall
convergence should use `base_firewall`; this role is for operator-triggered
repair when UFW is masked, `ufw enable` fails, or a host has mixed
`iptables-legacy` and `iptables-nft` state after upgrades.

## Features

- Installs an optional temporary systemd safety timer that runs `ufw disable`
- Unmasks and enables `ufw.service`
- Pins `iptables` and `ip6tables` to the nft backend
- Flushes legacy iptables tables
- Optionally flushes the nftables ruleset
- Optionally resets UFW cached rule state
- Optionally re-enables UFW after repair
- Stops and restarts Docker around backend repair when requested

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `base_firewall_repair_safety_net_enabled` | `true` | Install and start the temporary `ufw disable` safety timer |
| `base_firewall_repair_pin_nft_backend` | `true` | Set `iptables` and `ip6tables` alternatives to nft |
| `base_firewall_repair_flush_legacy_tables` | `true` | Flush legacy iptables tables |
| `base_firewall_repair_flush_nftables_ruleset` | `false` | Flush all nftables rules (destructive; opt-in) |
| `base_firewall_repair_reset_ufw` | `false` | Run `ufw --force reset` |
| `base_firewall_repair_enable_ufw_after` | `false` | Enable UFW after repair |
| `base_firewall_repair_stop_docker` | `true` | Stop Docker before backend repair |
| `base_firewall_repair_start_docker_after` | `true` | Start Docker after backend repair |
| `base_firewall_repair_safety_net_cleanup` | `false` | Stop and disable the safety timer at the end of the role run |

## Usage

Use the dedicated ops playbook rather than adding this role to recurring runs:

```bash
ansible-playbook -i inventory/prod.ini playbooks/ops/base_firewall_repair.yml
```

To enable UFW during the same run while the safety timer is active:

```bash
ansible-playbook -i inventory/prod.ini playbooks/ops/base_firewall_repair.yml \
  -e base_firewall_repair_enable_ufw_after=true
```

To also flush the entire nftables ruleset (destructive; opt-in):

```bash
ansible-playbook -i inventory/prod.ini playbooks/ops/base_firewall_repair.yml \
  -e base_firewall_repair_flush_nftables_ruleset=true
```

After confirming SSH still works, stop the safety timer:

```bash
sudo systemctl stop ufw-safedisable.timer
sudo systemctl disable ufw-safedisable.timer
```
