job "grafana" {
    datacenters = ["dc1"]
    mode = "host"
   
    group "grafana" {
        count = 1
        task "dashboard" {
            driver = "docker"
            config {
                image = "grafana/grafana:7.0.0"
            }
            resources {
                network {
                    mode = "host"
                    port "http_static" {
                        static = 3000
                    }
                }
            }
        }
        
    }
}