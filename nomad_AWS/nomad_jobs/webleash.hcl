job "web1" {
    datacenters = ["dc1"]

    group "website" {

        count = 3
        task "server" {
            driver = "docker"

            config {
                image = "webleash/cont_web_site:v1"
                network_mode = "host"
  

            }

            resources {
                network {
                    mbits = 10
                    port "nginx" {
                        static = 80
                    }

                }
            }

            }
        }
}



