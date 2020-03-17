output "elb_dns_name" {
  value = aws_elb.example.dns_name
}

output "db_port" {
  value = data.terraform_remote_state.db.outputs.port 
}

output "elb_security_group_id" {
  value = aws_security_group.elb.id 
}
