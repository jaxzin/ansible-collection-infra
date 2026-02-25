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
