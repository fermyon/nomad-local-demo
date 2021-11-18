# NOTE: Change the bindle to one on your local bindle in the 'args' below.
#
# Run this job
#
#     nomad run job/tote.nomad
#
# Get the job status
#
#     nomad job status tote
#
# Get the wagi logs using the Allocation ID from the status output
#
#     nomad logs -stderr 39023840-565b-c18f-5fef-4d74f98de9b4
#
# Test the endpoint
#
#     curl tote.local.fermyon.link:8088

job "tote" {
  datacenters = ["dc1"]
  type        = "service"

  group "tote" {
    count = 2

    network {
      port "http" {}
    }

    service {
      name = "tote"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.tote.rule=Host(`tote.local.fermyon.link`)",
      ]

      check {
        type     = "http"
        path     = "/healthz"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "server" {
      driver = "raw_exec"

      # artifact {
      #   source = "https://github.com/deislabs/wagi/releases/download/v0.4.0/wagi-v0.4.0-macos-amd64.tar.gz"
      #   options {
      #     checksum = "sha1:10bbcd1f7f1d369d2b3cf9b387cb71f84e9a9912"
      #   }
      # }

      # https://www.nomadproject.io/docs/job-specification/template#environment-variables
      template {
        data = <<EOH
FOO="{{with secret "kv/tote"}}{{.Data.foo}}{{end}}"
EOH

        destination = "secrets/file.env"
      }

      env {
        RUST_LOG   = "wagi=debug"
        BINDLE_URL = "http://bindle.local.fermyon.link:8088/v1"
      }

      config {
        command = "wagi"
        args = [
          "--listen", "${NOMAD_IP_http}:${NOMAD_PORT_http}",
          "--bindle", "tote/0.1.0",
          "--env-file", "secrets/file.env",
          "--log-dir", "local/logs",
        ]
      }
    }
  }
}
