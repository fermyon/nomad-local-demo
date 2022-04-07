#!/usr/bin/env bash
set -euo pipefail

export VAULT_ADDR='http://localhost:8200'
export VAULT_TOKEN='devroot'
export BINDLE_URL='http://bindle.local.fermyon.link:8088/v1'

require() {
  if ! hash "$1" &>/dev/null; then
    echo "'$1' not found in PATH"
    exit 1
  fi
}

require hippo

vault secrets enable kv 2>/dev/null || :
vault kv put kv/tote foo=bar

cargo cargo build --target wasm32-wasi --release
hippo bindle -v production HIPPOFACTS

echo "Starting tote job..."
nomad run tote.nomad
