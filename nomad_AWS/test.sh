#!/bin/bash
set -x
#mkdir -p /etc/nomad.d
#mkdir -p /export/nomad-data

server_dir="${HOME}server.hcl"
client_dir="${HOME}/nomad.hcl"

echo "server {" >$server_dir
echo "  enabled          = true" >>$server_dir
echo " bootstrap_expect = 1" >>$server_dir
echo "}" >>$server_dir

echo "advertise {" >>$server_dir
echo    "http = \"0.0.0.0\" " >>$server_dir
echo "}" >>$server_dir

echo "Built Server!"
cat $server_dir
echo "Building Client....."
echo "Getting public ip address"
pi=$(curl http://checkip.amazonaws.com)


echo "data_dir  = \"/export/nomad-data\"" >$client_dir
echo "datacenter = \"dc1\"" >>$client_dir
echo "log_level = \"DEBUG\"" >>$client_dir
echo "name = \"aws-ec2-client\"" >>$client_dir
echo "client {" >>$client_dir
echo "enabled = true" >>$client_dir
echo "  servers = [\"$pi\"]" >>$client_dir
echo "}" >>$client_dir



cat $client_dir

echo "Installing the binary"
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update -y && apt-get install -y nomad
nomad agent -config=/etc/nomad.d/
