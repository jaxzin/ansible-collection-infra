# Changelog

All notable changes to the `jaxzin.infra` collection are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this collection adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- CI: GitHub Actions workflow (`.github/workflows/lint.yml`) that runs
  `ansible-lint` on pushes to `main` and on pull requests, enforcing the
  repository's `.ansible-lint` configuration.
- `galaxy.yml`: declared `community.docker` (`>=3.0.0`) as a runtime dependency.
  The `tailscale_sidecar` role uses `community.docker.docker_container` and
  `community.docker.docker_container_exec`, so consumers must have the
  collection installed.
- `galaxy.yml`: added the `infrastructure` and `networking` Galaxy tags.

### Changed

- Raised the minimum supported Ansible to `>=2.15.0` (ansible-core 2.14 is
  end-of-life) in `meta/runtime.yml` and the role's `min_ansible_version`.

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
