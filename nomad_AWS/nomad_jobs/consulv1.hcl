job "consul" {
    datacenters = ["dc1"]
    type = "system"

    group "consul" {
        task "consul" {
            driver = "raw_exec"

            config {
                command = "curl"
                #sudo consul agent -dev -client 0.0.0.0 -bind 192.168.1.164  &
                args = ["-L","-o", "/opt/cni/bin", "0.0.0.0", "-bind", "192.168.1.164"]

            }

        }
    }
}