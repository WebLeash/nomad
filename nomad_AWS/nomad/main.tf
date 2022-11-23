module "vpc" {
  source = "../module/vpc"

  name                       = "nomad_vpc"
  region                     = var.aws-region
  cidr_block                 = "10.0.0.0/16"
  private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]
  public_subnet_cidr_blocks  = ["10.0.0.0/24", "10.0.2.0/24"]
  availability_zones         = ["us-east-1a", "us-east-1b"]

  project     = "Nomad"
  environment = "Development"
}


resource "aws_instance" "instance" {
  ami           = var.instance-ami
  instance_type = var.instance-type

  iam_instance_profile        = var.iam-role-name != "" ? var.iam-role-name : ""
  key_name                    = "ec2-aws_key-pair"
  associate_public_ip_address = var.instance-associate-public-ip
  # user_data                   = "${file("${var.user-data-script}")}"

  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  subnet_id              = module.vpc.public_subnet_id


  tags = {
    Name = "${var.instance-tag-name}"
  }


  user_data = <<EOF
#!/bin/bash
set -x
mkdir -p /etc/nomad.d
mkdir -p /export/nomad-data
pi=$(curl http://checkip.amazonaws.com)
server_dir="/etc/nomad.d/server.hcl"
client_dir="/etc/nomad.d/nomad.hcl"

echo "server {" >$server_dir
echo "  enabled          = true" >>$server_dir
echo " bootstrap_expect = 1" >>$server_dir
echo "}" >>$server_dir

echo "advertise {" >>$server_dir
echo    "http = \"$pi\" " >>$server_dir
echo "}" >>$server_dir

echo "Built Server!"
cat $server_dir
echo "Building Client....."
echo "Getting public ip address"
pi=$(curl http://checkip.amazonaws.com)


echo "data_dir  = \"/export/nomad-data\"" >$client_dir
echo "datacenter = \"dc1\"" >>$client_dir
echo "log_level = \"DEBUG\"" >>$client_dir
echo "name = \"nomad-resident-client-on-server\"" >>$client_dir
echo "client {" >>$client_dir
echo "enabled = true" >>$client_dir
echo "  servers = [\"$pi\"]" >>$client_dir
echo "}" >>$client_dir


echo "telemetry { " >>$client_dir
echo "  collection_interval = \"1s\" " >>$client_dir
echo "  disable_hostname = true  " >>$client_dir
echo "  prometheus_metrics = true   " >>$client_dir
echo "  publish_allocation_metrics = true " >>$client_dir
echo "  publish_node_metrics = true "  >>$client_dir
echo "} "  >>$client_dir


cat $client_dir

echo "Installing the binary"
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update -y && apt-get install -y nomad
nomad agent -config=/etc/nomad.d/ &

echo "Install Consul"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
apt update -y && apt install -y consul

apt install -y net-tools

consul_config="/etc/consul.d/consul.hcl"


>$consul_config
echo "datacenter = \"dc1\" " >$consul_config
echo "data_dir = \"/opt/consul\"" >>$consul_config
echo "client_addr = \"0.0.0.0\"" >>$consul_config
echo "ui_config{
  enabled = true
} " >>$consul_config
echo "server = true" >>$consul_config
echo "bind_addr = \"{{GetInterfaceIP \`eth0\`}}\"" >>$consul_config
echo "advertise_addr = \"{{ GetInterfaceIP \`ens5\` }}\"" >>$consul_config
echo "bootstrap_expect=1" >>$consul_config

echo "connect { ">>$consul_config
echo "  enabled = true " >>$consul_config
echo "} " >>$consul_config


systemctl start consul




EOF



  # provisioner "remote-exec" {
  #   inline = [
  #     "touch hello.txt",
  #     "echo helloworld remote provisioner >> hello.txt",
  #   ]
  # }
  #  connection {
  #   type        = "ssh"
  #   host        = self.public_ip
  #   user        = "ubuntu"
  #   private_key = file("/home/nathan/AWS_development/nomad/aws_key")
  #   timeout     = "4m"
  #} 
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ec2-aws_key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEuXvm9AKyRqFYCXo8qc1kswU+dRh5N6KXV7Stm1E3tTtf8GMGOUUXkgiDmaQ2+HLvlYUhRRUTIBRC4A0snoUaJSyMAn9H5wK4Kychf0uNu6HH6We3r0X88IXaZsoW/6OYDKSWh1uSVk+EvYQtIWYcR7PwSpbJt2x1i4eZuriwJyClee2dll7VfCWKI+0+1kRR0b5JMI4K4J3OheaTFgtFxG6rPq9mVdlKac7y+S3cvVrQ4aeJPwcXlIOZBtbUJK4TF/bDMD3oUEN86YaEmVLB5kzVjcthOOe6F020+OBe2r/2wM78lmtFJrCO5M1n91QJFRtLKTAsRHMc/mAkP7H3 nathan@nathan-XPS-8900"
}

resource "aws_security_group" "sg" {
  name   = var.sg-tag-name
  vpc_id = module.vpc.id

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "22"
    to_port     = "22"
  }

  ingress {
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
  }


  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "80"
    to_port     = "80"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "443"
    to_port     = "443"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "8080"
    to_port     = "8080"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "4646"
    to_port     = "4646"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "4647"
    to_port     = "4647"
  }
  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "4648"
    to_port     = "4648"
  }

  egress {
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "8500"
    to_port     = "8500"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "8300"
    to_port     = "8300"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "8301"
    to_port     = "8301"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "8600"
    to_port     = "8600"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.sg-tag-name}"
  }
}


resource "aws_instance" "nomad_client" {
  count = 2
  depends_on    = [aws_instance.instance]
  ami           = var.instance-ami
  instance_type = var.instance-type

  iam_instance_profile        = var.iam-role-name != "" ? var.iam-role-name : ""
  key_name                    = "ec2-aws_key-pair"
  associate_public_ip_address = var.instance-associate-public-ip
  # user_data                   = "${file("${var.user-data-script}")}"

  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  subnet_id              = module.vpc.public_subnet_id


  tags = {
    Name = "nomad-client"
  }


  user_data = <<EOF
#!/bin/bash
set -x
mkdir -p /etc/nomad.d
mkdir -p /export/nomad-data


client_dir="/etc/nomad.d/nomad.hcl"


echo "Building Client....."
echo "Getting public ip address"
pi="${aws_instance.instance.public_ip}"
private_ip=$(ec2metadata --local-ipv4)
ppi=$(curl http://checkip.amazonaws.com)

echo "data_dir  = \"/export/nomad-data\"" >$client_dir
echo "datacenter = \"dc1\"" >>$client_dir
echo "log_level = \"DEBUG\"" >>$client_dir
echo "name = \"aws-ec2-nomad_client\"" >>$client_dir
#echo "bind_addr = \"$private_ip\"" >>$client_dir
echo "advertise {" >>$client_dir
echo "http = \"$ppi\"">>$client_dir
echo "}" >>$client_dir
echo "client {" >>$client_dir
echo "enabled = true" >>$client_dir
echo "  servers = [\"$pi\"]" >>$client_dir
echo "}" >>$client_dir
echo "#### Telemetry">>$client_dir
echo "telemetry { "  >>$client_dir
echo "  collection_interval = \"1s\" " >>$client_dir
echo "  disable_hostname = true  " >>$client_dir
echo "  prometheus_metrics = true   "  >>$client_dir
echo "  publish_allocation_metrics = true " >>$client_dir
echo "  publish_node_metrics = true " >>$client_dir
echo "} " >>$client_dir

cat $client_dir

echo "Installing the binary"
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update -y && apt-get install -y nomad
nomad agent -config=/etc/nomad.d/ &


echo "Install Consul"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
apt update -y && apt install -y consul

apt install -y net-tools

consul_config="/etc/consul.d/consul.hcl"


>$consul_config
echo "datacenter = \"dc1\" " >$consul_config
echo "data_dir = \"/opt/consul\"" >>$consul_config
echo "client_addr = \"0.0.0.0\"" >>$consul_config
echo "server = false" >>$consul_config
echo "bind_addr = \"{{GetInterfaceIP \`eth0\`}}\"" >>$consul_config
echo "advertise_addr = \"{{GetInterfaceIP \`eth0\`}}\"" >>$consul_config

echo "retry_join = [\"$pi\"]" >>$consul_config
echo "ports { " >> $consul_config
echo "  grpc = 8502" >>$consul_config
echo "}" >>$consul_config


systemctl start consul

echo "Install CNI Plugins for Docker"
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
EOF



  # provisioner "remote-exec" {
  #   inline = [
  #     "touch hello.txt",
  #     "echo helloworld remote provisioner >> hello.txt",
  #   ]
  # }
  #  connection {
  #   type        = "ssh"
  #   host        = self.public_ip
  #   user        = "ubuntu"
  #   private_key = file("/home/nathan/AWS_development/nomad/aws_key")
  #   timeout     = "4m"
  #} 
}

