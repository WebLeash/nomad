job "nginx" {
  datacenters = ["dc1"]

  group "ng" {
    count = 1
    task "nginx" {
      driver = "docker"
      vault {
        policies = ["access-tables"]
      }
      template {
        data = <<EOT
          {{ with secret "secret/data/me" }}
          NAME ="{{ .Data.data.name }}"
          {{ end }}
      EOT
        destination = "/home/echo.env"
        env         = true
      }
      
      config {
 #       image = "hashicorp/http-echo:latest"
         image = "nginx:latest"
        
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