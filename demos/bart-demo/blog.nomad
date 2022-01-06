job "blog" {
  datacenters = ["dc1"]
  type        = "service"

  group "blog" {
    count = 

    network {
      port "http" {}
    }

    service {
      name = "blog"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.blog.rule=Host(`blog.local.fermyon.link`)",
      ]

      check {
        name = "alive"
        type = "tcp"
        interval = "10s"
        timeout = "2s"
      }
    }

    task "server" {
      driver = "raw_exec"

      artifact {
        source = "https://github.com/deislabs/wagi/releases/download/v0.4.0/wagi-v0.4.0-macos-amd64.tar.gz"
        options {
          checksum = "sha1:10bbcd1f7f1d369d2b3cf9b387cb71f84e9a9912"
        }
      }

      env {
        RUST_LOG   = "wagi=debug"
        BINDLE_URL = "http://bindle.local.fermyon.link:8088/v1"
      }

      config {
        command = "wagi"
        args = [
          "--listen", "${NOMAD_IP_http}:${NOMAD_PORT_http}",
          "--bindle", "blog-name/0.1.0",
          "--log-dir", "local/logs",
        ]
      }
    }
  }
}