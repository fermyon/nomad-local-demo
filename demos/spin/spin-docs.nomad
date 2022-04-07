variable "bindle_id" {
  type        = string
  default     = "spin-docs/0.1.0"
  description = "A bindle id, such as foo/bar/1.2.3"
}

variable "bindle_url" {
  type        = string
  default     = "http://bindle.local.fermyon.link:8088/v1"
  description = "The Bindle server URL"
}

job "spin-docs" {
  datacenters = ["dc1"]
  type        = "service"

  group "spin-docs" {
    network {
      port "http" {}
    }

    service {
      name = "spin-docs"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.spin-docs.rule=Host(`spin-docs.local.fermyon.link`)",
      ]

      check {
        name     = "alive"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }

    }

    task "server" {
      driver = "raw_exec"

      env {
        RUST_LOG   = "spin=debug"
        BINDLE_URL = var.bindle_url
      }

      config {
        command = "spin"
        args = [
          "up",
          "--listen", "${NOMAD_IP_http}:${NOMAD_PORT_http}",
          "--bindle", var.bindle_id,
          "--server", var.bindle_url,
          "--log-dir", "${NOMAD_ALLOC_DIR}/logs",
          "--temp", "${NOMAD_ALLOC_DIR}/tmp",

          # Use https://github.com/deislabs/wagi-fileserver/pull/10 as a workaround
          # for https://github.com/deislabs/hippo-cli/issues/39
          # "-e", "PATH_PREFIX=static/",

          # This tells favicon.wasm where its favicon.ico file is.
          # "-e", "FAVICON_PATH=/static/image/icon/favicon.ico",

          # Set BASE_URL for Bartholomew to override default (localhost:3000)
          "-e", "BASE_URL=http://spin-docs.local.fermyon.link:8088",

          # If staging, add -k to accept cert failures with the bindle server
          # TODO: requires https://github.com/deislabs/wagi/pull/165
          # "${var.env == "staging" ? "-k" : ""}",
        ]
      }

    }
  }
}
