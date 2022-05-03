variable "domain" {
  type        = string
  default     = "hippo.local.fermyon.link"
  description = "hostname"
}

variable "bindle_url" {
  type        = string
  default     = "http://bindle.local.fermyon.link:8088/v1"
  description = "The Bindle server URL"
}

job "hippo" {
  datacenters = ["dc1"]
  type        = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "hippo" {
    count = 1

    network {
      port "http" {
        static = 5000
      }
    }

    service {
      name = "hippo"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.hippo.rule=Host(`${var.domain}`)",
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
        source = "https://github.com/deislabs/hippo/releases/download/v0.7.0/hippo-server-linux-x64.tar.gz"
      }

      env {
        Hippo__PlatformDomain = var.domain
        Scheduler__Driver     = "nomad"
        Hippo__PlatformDomain = "local.fermyon.link"

        # Database Driver: inmemory, sqlite, postgresql
        Database__Driver            = "sqlite"
        ConnectionStrings__Database = "Data Source=hippo.db;Cache=Shared"

        # Database__Driver            = "postgresql"
        # ConnectionStrings__Database = "Host=localhost;Username=postgres;Password=postgres;Database=hippo"

        Bindle__Url = var.bindle_url

        Jwt__Key      = "ceci n'est pas une jeton"
        Jwt__Issuer   = "localhost"
        Jwt__Audience = "localhost"

        Kestrel__Endpoints__Https__Url = "http://${NOMAD_IP_http}:${NOMAD_PORT_http}"
      }

      config {
        command = "bash"
        args    = ["-c", "cd local/linux-x64 && ./Hippo.Web"]
      }
    }
  }
}
