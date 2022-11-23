output "aws_vpc_id" {
  value       = module.vpc.id
  description = "VPC ID"
}
# module.<module_name>.<output_value_name>
output "aws_public_subnet_id" {
  value = module.vpc.public_subnet_id

}

output "public_ip_address_nomad_server" {
  value = aws_instance.instance.public_ip
}

#output "nomad_client_private_ip" {
#  value = aws_instance.nomad_client.private_ip
#}