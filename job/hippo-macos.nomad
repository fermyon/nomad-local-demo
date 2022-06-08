variable "domain" {
  type        = string
  default     = "local.fermyon.link"
  description = "hostname"
}

job "hippo" {
  datacenters = ["dc1"]
  type        = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "darwin"
  }

  group "hippo" {
    count = 1

    network {
      port "http" {
        static = 5309
      }
    }

    service {
      name = "hippo"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.hippo.rule=Host(`hippo.${var.domain}`)",
      ]

      check {
        name     = "alive"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "hippo" {
      driver = "raw_exec"

      artifact {
        source = "https://github.com/deislabs/hippo/releases/download/v0.10.0/hippo-server-osx-x64.tar.gz"
      }

      env {
        Hippo__PlatformDomain = var.domain

        Database__Driver            = "sqlite"
        ConnectionStrings__Database = "Data Source=hippo.db;Cache=Shared"

        Jwt__Key      = "ceci n'est pas une jeton"
        Jwt__Issuer   = "localhost"
        Jwt__Audience = "localhost"

        Kestrel__Endpoints__Https__Url = "http://${NOMAD_IP_http}:${NOMAD_PORT_http}"
      }

      config {
        command = "bash"
        args    = ["-c", "cd local/osx-x64 && ./Hippo.Web"]
      }
    }
  }
}
