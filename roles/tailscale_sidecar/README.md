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
