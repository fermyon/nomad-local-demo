# Nomad demo

Start consul, nomad, and vault, traefik, and bindle

```
$ ./run_servers.sh
```

Set BINDLE_URL in your shell

```
$ export BINDLE_URL="http://bindle.local.fermyon.link:8088/v1"
```

Build example bindle and push to bindle server

```
$ cd tote
$ cargo build-wasm --release
$ hippo bindle -v production HIPPOFACTS
```

Run the nomad job

```
$ nomad run job/tote.nomad
```

Get the job status and the allocation ID's

```
$ nomad job status tote
```

Get the wagi logs using the allocation ID from the status output

```
$ nomad logs -stderr ee0974b9
Nov 15 10:38:13.824  INFO wagi::wagi_app: Starting server addr=192.168.1.16:31445
Nov 15 10:38:13.826 DEBUG wagi::wagi_app: Env vars are set env_vars={"FOO": "bar"}
Nov 15 10:38:13.846  INFO wagi::wasm_runner: Using log dir log_dir=local/logs/8a5edab282632443219e051e4ade2d1d5bbc671c781051bf1437897cbdfea0f1
```

Test the endpoint

```
$ curl tote.local.fermyon.link:8088
Hello, world!
```

Get wagi module logs from the allocation's filesystem

```
$ nomad alloc fs ee0974b9 server/local/logs/8a5edab282632443219e051e4ade2d1d5bbc671c781051bf1437897cbdfea0f1/module.stderr
Error log for tote
```
