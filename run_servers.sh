#!/usr/bin/env bash
set -euo pipefail

export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=devroot

require() {
  if ! hash "$1" &>/dev/null; then
    echo "'$1' not found in PATH"
    exit 1
  fi
}

require bindle-server
require consul
require nomad
require traefik
require vault

cleanup() {
  echo
  echo "Shutting down services"
  kill $(jobs -p)
  wait
}

trap cleanup EXIT

rm -rf ./data
mkdir -p log

# https://www.nomadproject.io/docs/faq#q-how-to-connect-to-my-host-network-when-using-docker-desktop-windows-and-macos

IP_ADDRESS=127.0.0.1

echo "Starting consul..."
consul agent -dev \
  -config-file ./etc/consul.hcl \
  -bootstrap-expect 1 \
  -client '0.0.0.0' \
  -bind "${IP_ADDRESS}" \
  &>log/consul.log &

echo "Starting vault..."
vault server -dev \
  -dev-root-token-id "$VAULT_TOKEN" \
  -config ./etc/vault.hcl \
  &>log/vault.log &

echo "Waiting for vault..."
while ! grep -q 'Unseal Key' <log/vault.log; do
  sleep 2
done

echo "Storing unseal token in ./data/vault/unseal"
if [ ! -f data/vault/unseal ]; then
  awk '/^Root Token:/ { print $NF }' <log/vault.log >data/vault/token
  awk '/^Unseal Key:/ { print $NF }' <log/vault.log >data/vault/unseal
fi

echo "Starting nomad..."
nomad agent -dev \
  -config ./etc/nomad.hcl \
  -data-dir "${PWD}/data/nomad" \
  -consul-address "${IP_ADDRESS}:8500" \
  -vault-address http://${IP_ADDRESS}:8200 \
  -vault-token "${VAULT_TOKEN}" \
   &>log/nomad.log &

echo "Waiting for nomad..."
while ! nomad server members 2>/dev/null | grep -q alive; do
  sleep 2
done

echo "Starting traefik job..."
nomad run job/traefik.nomad

echo "Starting bindle job..."
nomad run job/bindle.nomad

echo "Starting hippo job..."
case "${OSTYPE}" in
darwin*)
  echo "Hippo on MacOS requires raw_exec support"
  echo "  ref: https://github.com/deislabs/hippo/pull/695"
  nomad run job/hippo-macos.nomad
	;;
linux*)
  nomad run job/hippo-linux.nomad
	;;
*)
  echo "Hippo is only started on MacOS and Linux"
  ;;
esac


echo
echo "Dashboards"
echo "----------"
echo "Consul:  http://localhost:8500"
echo "Nomad:   http://localhost:4646"
echo "Vault:   http://localhost:8200"
echo "Traefik: http://localhost:8081"
echo "Hippo:   http://localhost:5309"
echo
echo "Logs are stored in ./log"
echo
echo "Export these into your shell"
echo
echo "    export CONSUL_HTTP_ADDR=http://localhost:8500"
echo "    export NOMAD_ADDR=http://localhost:4646"
echo "    export VAULT_ADDR=${VAULT_ADDR}"
echo "    export VAULT_TOKEN=$(<data/vault/token)"
echo "    export VAULT_UNSEAL=$(<data/vault/unseal)"
echo "    export BINDLE_URL=http://localhost:8080/v1"
echo "    export HIPPO_URL=http://localhost:5309"
echo
echo "Ctrl+C to exit."
echo

wait
