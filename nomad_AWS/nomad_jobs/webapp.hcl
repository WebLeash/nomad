job "webapp-consul-webleash" {
	datacenters = ["dc1"]

	group "website" {
        count = 2
		network {
			mode = "host"
			port "http" {
				static = "8501"
				to = "80"
			}
		}

		task "app" {
			driver = "docker"

			config {
				image = "webleash/cont_web_site:v1"
				ports = ["http"]
			}
		}
		resources {
            network {
            mbits = 10
            port "http" {
            static = 8080
          }
        }
      }
        
	}
}
