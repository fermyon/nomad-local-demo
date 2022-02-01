# Bartholomew Demo

Deploy a blog on Nomad using Bartholomew

## Prerequisites

Set up Nomad environment using the [./run-servers.sh script](/run-servers.sh) at the root of this repository and export the BINDLE_URL environment variable as directed:

```console
export BINDLE_URL="http://bindle.local.fermyon.link:8088/v1"
```

## Create a Blog Application using Bartholomew aka Bart

Generate a blog using the Bartholomew CMS in one of two ways:
1. Create a new repository from the Bartholomew site template repo and download the necessary released wasm files from the Bartholomew repo.
2. Clone the Bartholomew repo and generate the necessary wasm files from source.

Use option 1 if you don't care to generate the wasm files yourself.

## Run Blog Application Locally

Check to see if everything works as expected.

```console
wagi -c modules.toml
curl localhost:3000
```

## Package Blog as a Bindle and Push to Bindle Registry

First, create a file called `HIPPOFACTS` for the blog application containing the following toml. Replace `blog-name` with the name of your blog.

```toml
[bindle]
name = "blog-name"
version = "0.1.0"

[[handler]]
# Download the Wagi fileserver, and then set this path to point to fileserver.gr.wasm
name = "fileserver.gr.wasm"
route = "/static/..."
files = ["static/*/*"]

[[handler]]
# Download the Bartholomew server and then set this path to point to bartholomew.wasm
name = "bartholomew.wasm"
route = "/..."
files = [ "contents/**/*" , "templates/*", "scripts/*", "config/*"]
```

Package and puhs the bindle to the bindle registry running locally with the following command.

```console
hippo bindle -v production HIPPOFACTS
```

## Deploy Blog on Nomad

Use the `blog.nomad` file in this repo to deploy your blog on to the nomad cluster running locally. Replace `blog-name` with the name specified in the HIPPOFACTS file.

To deploy, use the following command:

```console
nomad run blog.nomad
```

Get the job status:

```console
nomad job status blog
```

Get the wagi logs using the Allocation ID from the status output

```console
nomad logs -stderr <alloc-id>
```

Take note of the temp directory created in local/logs listed in the stderr log output.

Test the endpoint:

```console
curl blog.local.fermyon.link:8088
```

Check logs from the blog by accessing wagi module logs from the allocation's filesystem using the local/logs path found above.

```console
nomad alloc fs <alloc-id> server/local/logs/<some-long-hash>/module.stderr
```