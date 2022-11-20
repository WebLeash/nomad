job "http-echo" {
  datacenters = ["dc1"]

  group "echo" {
    count = 1
    task "server" {
      driver = "docker"
      vault {
        policies = ["access-tables"]
      }
      template {
        data = <<EOT
          {{ with secret "kv/me" }}
          NAME ="{{ .Data.data.name }}"
          {{ end }}
      EOT
        destination = "echo.env"
        env         = true
      }
      
      config {
        image = "hashicorp/http-echo:latest"
        args  = [
          "-listen", ":8080",
          "-text", "Hello World!",
        ]
      }

      resources {
        network {
          mbits = 10
          port "http" {
            static = 8080
          }
        }
      }

      service {
        name = "http-echo"
        port = "http"

        tags = [
          "urlprefix-/http-echo",
        ]
      }
    }
  }
}
