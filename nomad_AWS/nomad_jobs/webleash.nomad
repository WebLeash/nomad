job "webleash" {
  datacenters = ["dc1"]
  #type = "service"

  group "webleash" {
    count = 3
    network {
      port "http" {
        to = 80
      }
    }

    service {
      name = "webleash-website"
      tags = ["urlprefix-/web"]
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

    task "webleash" {
      driver = "docker"
      config {
        image = "webleash/cont_web_site:v1"
        ports = ["http"]
      }
    }
  }
}
