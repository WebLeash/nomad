job "webserver" {
  datacenters = ["dc1"]
  type = "service"

  group "webserver" {
    count = 2
    network {
      port "http" {
        to = 80
      }
    }

    service {
      name = "website-webleash"
      tags = ["urlprefix-/webleash strip=/webleash"]
      port = "http"
      check {
        name     = "alive"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "apache" {
      driver = "docker"
      config {
        image = "webleash/cont_web_site:v1"
        ports = ["http"]
      }
    }
  }
}
