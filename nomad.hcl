telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}

vault {
  enabled = true
  address = "http://localhost:8200"
  task_token_ttl = "1h"
  create_from_role = "nomad-cluster"
  token = "hvs.CAESIC7RnAtqg9p78nSZ_xC3GN0PbJVJFR_vX0xjJlrOtc-LGh4KHGh2cy5jS01KU3ZOcGhpMlVnaGxjTXRuS0NNZEs"
}




