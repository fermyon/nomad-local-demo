# Fermyon website demo

## Bundle it up

```
export BINDLE_URL=http://bindle.local.fermyon.link:8088/v1

spin bindle prepare --file spin.toml --staging-dir out

bindle sign-invoice \
  --out out/47ff40e9483bef56a2c2ace442f697ae1229cf7f3d48563b514c94185d226c4e/invoice.toml \
  out/47ff40e9483bef56a2c2ace442f697ae1229cf7f3d48563b514c94185d226c4e/invoice.toml

bindle push -p /Users/areese/p/src/github.com/fermyon/fermyon.com/out spin-fermyon.com/0.1.0
```

## Nomad

```
nomad run job/website-spin.nomad

nomad logs -job website
```

[Party](http://fermyon.local.fermyon.link:8088)
