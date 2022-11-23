# Create Client for nomad


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


client_dir="/etc/nomad.d/nomad.hcl"


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

  tags = {
    Name = "${var.sg-tag-name}"
  }
} 