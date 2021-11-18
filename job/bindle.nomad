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
        "traefik.http.routers.bindle.rule=Host(`bindle.local.fermyon.link`)",
      ]

      # only works on bindle main
      # check {
      #   type     = "http"
      #   path     = "/healthz"
      #   interval = "10s"
      #   timeout  = "2s"
      # }

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
