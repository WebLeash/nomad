job "webleash" {

    datacenters = ["dc1"]

    group "echo" {
        count = 1
        task "server"{
            driver = "docker"

            config {
                image = "webleash/cont_web_site:v1"
                }

            resources {
                network {
                    mbits = 10
                    port "http" {
                        static = "80"
                    }
                }
            }
            }
        }
    }

