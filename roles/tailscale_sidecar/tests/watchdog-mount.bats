#!/usr/bin/env bats
# The watchdog script must be bind-mounted via its DIRECTORY, never as a
# single file. ansible.builtin.copy replaces the host file by atomic rename
# (a new inode); a single-file bind mount pins the old inode, so a running
# sidecar keeps executing the deleted script until it is recreated. Every
# watchdog fix shipped that way was silently not applied
# (ansible-collection-infra#23).

TASKS="${BATS_TEST_DIRNAME}/../tasks/main.yml"

sidecar_task() {
  awk '/^- name: Deploy Tailscale sidecar container/{f=1} f&&/^- name: Wait for Tailscale to connect/{exit} f' "$TASKS"
}

@test "watchdog mount: the host DIRECTORY is mounted, not the script file" {
  run sidecar_task
  [ "$status" -eq 0 ]
  [[ "$output" == *"tailscale_dns_watchdog_host_dir ~ ':/opt/dns-watchdog:ro'"* ]]
  [[ "$output" != *"/dns-watchdog.sh:/usr/local/bin/dns-watchdog.sh"* ]]
}

@test "watchdog mount: healthcheck runs the script from the mounted directory" {
  run sidecar_task
  [[ "$output" == *"'/opt/dns-watchdog/dns-watchdog.sh'"* ]]
  [[ "$output" != *"/usr/local/bin/dns-watchdog.sh"* ]]
}
