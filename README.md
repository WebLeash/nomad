# nomad
## Step 1
### Create nomad cluster - sudo  nomad agent -dev  -config=/etc/nomad.d/nomad.hcl
### nomad/hcl below

vault {
  enabled = true
  address = "http://localhost:8200"
  task_token_ttl = "1h"
  create_from_role = "nomad-cluster"
  token = "hvs.CAESIC7RnAtqg9p78nSZ_xC3GN0PbJVJFR_vX0xjJlrOtc-LGh4KHGh2cy5jS01KU3ZOcGhpMlVnaGxjTXRuS0NNZEs"
}

## Create cluster Role with policy.
## write policy that will be accessed by the stanza
## Ensure job Stanza has the correct reference to secret.<br> {{ with secret \"secret/data/me\" }}<br>
## Ensure  Consul is running. <br> consul agent -dev
## give the Token to nomad generated from the cluster Role.
## Ensure all policies are added. <br> vault policy list
