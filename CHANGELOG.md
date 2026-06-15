# Changelog

## [1.2.0] - 2026-06-15

### Added

- `tailscale_sidecar`: configurable `tailscale_log_driver` /
  `tailscale_log_options` (default `json-file`) so the sidecar avoids the
  Synology ContainerManager `db` log driver, which wedges and breaks
  healthcheck execs and container restarts.

## [1.1.0] - 2026-05-05

### Added

- `tailscale_sidecar`: configurable container memory limits
  (`tailscale_memory_limit` / `tailscale_memory_swap`).
- `tailscale_sidecar`: configurable `TS_ACCEPT_DNS` via `tailscale_accept_dns`,
  for sidecars that must resolve other containers via Docker's embedded DNS.

## [1.0.0] - 2026-02-25

### Added

- Initial release of the `jaxzin.infra` collection with the `tailscale_sidecar`
  role: deploys a Tailscale sidecar container with an optional Tailscale Serve
  HTTPS reverse proxy.
