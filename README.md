# Nomad demo

## Install prerequisites

Download nomad, consul, traefik, bindle, and the hippo CLI and make these binaries
available in your $PATH.

## Start necessary services

Start consul, nomad, traefik, and bindle

```
$ ./run_servers.sh
```

Follow the [Spin documentation](https://spin.fermyon.dev/) or [Hippo documentation](https://docs.hippofactory.dev/) to get started.

## Troubleshooting

If you run into an IPv6 issue you can set IPv6 to link-local for an interface.

```
networksetup -setv6linklocal Wi-Fi
```

To get a list of interface names

```
networksetup -listallnetworkservices
```
