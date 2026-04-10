# docs/08-docker-traefik-downstream-services.md

Reference for Docker services that sit behind `docker_traefik`.
Explains how future Docker service roles should join the shared Traefik proxy
network, when to use Compose labels, and how to model host-versus-container
ports for services that also expose non-HTTP listeners such as DNS.

## Purpose

Some Docker services in this repository need two different access paths:

- an HTTP or HTTPS web UI published through Traefik
- a separate non-HTTP service published directly on the host

`docker_adguard` is the current example, and `docker_wireguard` now follows the
same split-host-port plus Traefik-web-UI pattern:

- the web UI is published through Traefik
- DNS is published directly from the container to a host port

This pattern is useful for future services that have both:

- a browser-facing admin UI
- a second protocol Traefik does not proxy in the current role model

## Network Pattern

Use the Traefik-owned external Docker network for the web UI path.

The downstream service Compose file should:

1. join the external proxy network created by `docker_traefik`
2. set Traefik router and service labels on its own container
3. avoid adding more Traefik file-provider config unless the service really
   needs shared Traefik-side middleware or a non-label routing pattern

Example shape:

```yaml
services:
  app:
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network={{ docker_traefik_network_name }}"
      - "traefik.http.routers.app.rule=Host(`app.example.com`)"
      - "traefik.http.routers.app.entrypoints=websecure"
      - "traefik.http.routers.app.tls=true"
      - "traefik.http.routers.app.tls.certresolver=letsencrypt"
      - "traefik.http.services.app.loadbalancer.server.port=3000"

networks:
  proxy:
    external: true
    name: "{{ docker_traefik_network_name }}"
```

This keeps each service role self-contained while still reusing the shared
Traefik reverse proxy.

## Inventory Alias Hostnames

When the inventory defines a per-host `alias`, the example Docker layer can
use that alias to derive public URLs for Traefik-published dashboards.

Example pattern:

```yaml
docker_public_host_alias: "{{ alias | default(inventory_hostname) }}"
docker_public_domain_suffix: "{{ vault_docker_public_domain_suffix }}"
docker_traefik_dashboard_host: "traefik.{{ docker_public_host_alias }}.{{ docker_public_domain_suffix }}"
docker_adguard_host: "adguard.{{ docker_public_host_alias }}.{{ docker_public_domain_suffix }}"
docker_adguard_sync_host: "adguard-sync.{{ docker_public_host_alias }}.{{ docker_public_domain_suffix }}"
docker_wireguard_host: "wireguard.{{ docker_public_host_alias }}.{{ docker_public_domain_suffix }}"
```

This keeps host-specific dashboard names predictable while storing only the
shared domain suffix in Vault rather than repeating full FQDNs per service.

For a host with `alias=proxy1`, this produces:

- `traefik.proxy1.example.com`
- `adguard.proxy1.example.com`
- `adguard-sync.proxy1.example.com`
- `wireguard.proxy1.example.com`

If you adopt this pattern, keep DNS aligned with it through either:

- explicit records for each derived hostname
- a wildcard DNS record plus local rewrite behavior when your service model
  supports that

The key rule is that the inventory alias pattern and the live DNS resolution
pattern must match, or the Traefik routers will be configured for names that
clients cannot resolve.

## Host Port Versus Container Port

When the service also exposes a non-HTTP port directly on the host, keep the
host port and the container-internal port as separate variables.

This is the key rule.

Do not reuse one variable for both sides of the mapping unless they are
intentionally always the same.

Example:

```yaml
app_host_dns_port: 5353
app_container_dns_port: 53
```

Then render the files like this:

```yaml
ports:
  - "{{ app_host_dns_port }}:{{ app_container_dns_port }}/tcp"
  - "{{ app_host_dns_port }}:{{ app_container_dns_port }}/udp"
```

```yaml
dns:
  port: {{ app_container_dns_port }}
```

Why this matters:

- the host may need a non-default port in the example lab because something
  else already binds the standard port
- the application inside the container often still expects its standard
  protocol port
- using one variable for both can make Docker publish one port while the app
  listens on another

`docker_adguard` and `docker_wireguard` use this exact split approach:

- `docker_adguard_dns_bind_port`: host-published port
- `docker_adguard_container_dns_port`: internal AdGuard DNS listener port

## Firewall Pattern

If the downstream service exposes a direct host port, register firewall rules
through `base_firewall_role_declared_rules`.

Use the host-published port for firewall rules, not the container-internal
port.

Example:

```yaml
app_manage_firewall_rules: true
app_firewall_rules:
  - rule: allow
    direction: in
    port: "{{ app_host_dns_port | string }}"
    proto: tcp
    comment: "managed:app:dns-tcp"
  - rule: allow
    direction: in
    port: "{{ app_host_dns_port | string }}"
    proto: udp
    comment: "managed:app:dns-udp"
```

Then have the role append those rules during config, and run `base_firewall`
after the service role if you want UFW to enforce them in the same playbook
flow.

## When To Use This Pattern

Use this Traefik-plus-direct-port pattern when:

- the service has a web UI that fits normal HTTP or HTTPS reverse proxying
- the service also exposes another protocol directly to clients
- the direct protocol should remain bind-mounted and backup-friendly under
  `/srv/<service>/data`

Examples that fit this model:

- DNS services
- web apps with additional TCP or UDP listener ports
- admin tools that have both a browser UI and a direct client protocol

## When Not To Use It

Do not use this pattern when:

- the service only needs HTTP or HTTPS
  then use Traefik labels only and skip direct host ports
- the service must own the full host network stack
  then a host-network design may be more appropriate, but that is a different
  convention than the current `docker_adguard` role

## Summary

For future Docker roles that behave like `docker_adguard` or
`docker_wireguard`:

- join the shared Traefik proxy network
- publish the web UI with Compose labels
- keep host ports and container ports separate variables
- register firewall rules for the host-published port only
- keep service data under `/srv/<service>/data`
