# Spin docs website demo

First install the spin binary by following the [quickstart](https://spin.fermyon.dev/quickstart/).

## Clone the spin repository

```
git clone https://github.com/fermyon/spin.git
cd spin/docs
```

## Bundle it up

```
export BINDLE_URL=http://bindle.local.fermyon.link:8088/v1

spin bindle push --file spin.toml
```

## Run the nomad job

```
nomad run ./spin-docs.nomad
```

The site will be accessible at [http://spin-docs.local.fermyon.link:8088](http://spin-docs.local.fermyon.link:8088)

## Check the logs

```
nomad logs -stderr -job spin-docs
```
