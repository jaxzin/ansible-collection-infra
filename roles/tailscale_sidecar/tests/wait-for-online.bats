#!/usr/bin/env bats
# The connect wait must test the same condition as the online assert that
# follows it. A wait that stops at BackendState=Running races the control
# plane after a container recreate (ansible-collection-infra#18).

TASKS="${BATS_TEST_DIRNAME}/../tasks/main.yml"

wait_task() {
  awk '/^- name: Wait for Tailscale to connect to tailnet/{f=1} f&&/^- name: Parse final Tailscale status/{exit} f' "$TASKS"
}

@test "connect wait requires Self.Online, not only BackendState" {
  run wait_task
  [ "$status" -eq 0 ]
  [[ "$output" == *'BackendState'* ]]
  [[ "$output" == *'Self.Online'* ]]
}

@test "online assert still follows the wait" {
  run grep -c "ts_state.Self.Online | default(false) | bool" "$TASKS"
  [ "$output" -ge 1 ]
}
