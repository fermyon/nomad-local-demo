job "bindle" {
  datacenters = ["dc1"]
  type        = "service"

  group "bindle" {
    count = 1

    network {
      port "http" {}
    }

    service {
      name = "bindle"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Host(`bindle.local.reese.io`)",
      ]

      check {
        type     = "http"
        # change to "/healthz" after https://github.com/deislabs/bindle/pull/259
        path     = "/v1/healthz"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "server" {
      driver = "raw_exec"

      env {
        RUST_LOG = "error,bindle=debug"
      }

      config {
        command = "bindle-server"
        args = [
          "--unauthenticated",
          "--address", "${NOMAD_IP_http}:${NOMAD_PORT_http}",
        ]
      }
    }
  }
}
