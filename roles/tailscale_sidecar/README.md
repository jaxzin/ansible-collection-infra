# tailscale_sidecar

Deploys a Tailscale sidecar container with optional [Tailscale Serve](https://tailscale.com/kb/1312/serve) reverse proxy.

## Requirements

- `community.docker` collection
- Docker on the target host

## Role Variables

See `defaults/main.yml` for defaults and `meta/main.yml` for full argument specs.

### Required

| Variable | Description |
|----------|-------------|
| `tailscale_container_name` | Name for the Tailscale sidecar container |
| `tailscale_hostname` | Hostname on the tailnet |
| `tailscale_authkey` | Tailscale auth key |
| `tailscale_state_dir` | Host path for persistent Tailscale state |
| `tailscale_network_name` | Docker network to join |

### Serve (optional)

| Variable | Default | Description |
|----------|---------|-------------|
| `tailscale_serve_enabled` | `false` | Enable Tailscale Serve reverse proxy |
| `tailscale_serve_config_dir` | `""` | Host path for serve config |
| `tailscale_serve_domain` | `""` | FQDN for the HTTPS endpoint |
| `tailscale_serve_proxy_host` | `127.0.0.1` | Backend host to proxy to |
| `tailscale_serve_proxy_port` | `""` | Backend port to proxy to |

### DNS

| Variable | Default | Description |
|----------|---------|-------------|
| `tailscale_accept_dns` | `true` | Whether tailscaled takes over `/etc/resolv.conf`. Set to `false` when the sidecar lives on a Docker bridge network and `tailscale_serve_proxy_host` is a Docker DNS name (e.g., `myapp-server`); otherwise tailscaled rewrites resolv.conf to point only at MagicDNS (`100.100.100.100`), which can't resolve Docker peer names. |

### DNS self-heal & upstream watchdog

In kernel-mode + shared-netns deployments, `tailscaled` can finish startup
without applying the tailnet DNS config to its forwarder (`DefaultResolvers`
ends up empty), so MagicDNS (`100.100.100.100`) returns **SERVFAIL for every
query** and all outbound DNS in the shared netns breaks silently — while the
serve/funnel path keeps working. See
[issue #7](https://github.com/jaxzin/ansible-collection-infra/issues/7).

The role installs a healthcheck script (`dns-watchdog.sh`) on the sidecar that,
on each interval:

1. **Downstream heal** — re-prepends Docker's embedded resolver (`127.0.0.11`)
   to `/etc/resolv.conf` so containers sharing this netns keep resolving Docker
   service names (tailscaled strips it on every restart).
2. **Upstream watchdog** — when `tailscale_accept_dns` is `true`, probes an
   external name against MagicDNS; if it SERVFAILs, it bounces
   `accept-dns` false→true to force tailscaled to re-apply its DNS config
   (verified non-disruptive). After the bounce it re-probes and reports the
   container `unhealthy` only if DNS is still broken — informational only, since
   `restart_policy: always` does not restart unhealthy containers.

| Variable | Default | Description |
|----------|---------|-------------|
| `tailscale_dns_watchdog_enabled` | `true` | Enable the self-heal + watchdog healthcheck. Disabling removes both halves. |
| `tailscale_dns_servers` | `["100.100.100.100"]` | Container `dns_servers`; gives `127.0.0.11` a working upstream. `[]` leaves Docker's default. |
| `tailscale_dns_probe_name` | `one.one.one.one` | External name the watchdog resolves. |
| `tailscale_dns_probe_resolver` | `100.100.100.100` | Resolver the watchdog queries. |
| `tailscale_dns_watchdog_interval` | `15s` | Healthcheck interval. |
| `tailscale_dns_watchdog_timeout` | `10s` | Healthcheck timeout. |
| `tailscale_dns_watchdog_retries` | `3` | Failures before reported unhealthy. |
| `tailscale_dns_watchdog_start_period` | `10s` | Grace period before failures count. |
| `tailscale_dns_watchdog_host_dir` | sibling of `tailscale_state_dir` (…/tailscale-dns-watchdog) | Host dir the script is installed into and mounted from. |

### Logging

| Variable | Default | Description |
|----------|---------|-------------|
| `tailscale_log_driver` | `json-file` | Docker logging driver for the sidecar. Defaults to `json-file` (local-file logging) so the container never lands on the Synology ContainerManager `db` driver, which wedges and breaks healthchecks + restarts. |
| `tailscale_log_options` | `{max-size: "10m", max-file: "3"}` | Driver-specific log options. The default rotates json-file logs at 10 MB, keeping 3 files. Must be compatible with `tailscale_log_driver` if overridden. |

## Example Playbook

```yaml
- role: jaxzin.infra.tailscale_sidecar
  vars:
    tailscale_container_name: tailscale-myapp
    tailscale_hostname: myapp
    tailscale_authkey: "{{ lookup('ansible.builtin.env', 'TS_AUTHKEY') }}"
    tailscale_state_dir: /volume1/docker/myapp/tailscale-state
    tailscale_network_name: myapp-net
    tailscale_serve_enabled: true
    tailscale_serve_config_dir: /volume1/docker/myapp/tailscale-serve-config
    tailscale_serve_domain: "myapp.example.ts.net"
    tailscale_serve_proxy_port: "3000"
```

## License

MIT
