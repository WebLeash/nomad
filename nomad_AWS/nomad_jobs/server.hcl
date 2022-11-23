server {
  # license_path is required as of Nomad v1.1.1+
  #license_path = "/opt/nomad/license.hclic"
  enabled          = true
  bootstrap_expect = 1
}

advertise {
   http = "0.0.0.0"
}
