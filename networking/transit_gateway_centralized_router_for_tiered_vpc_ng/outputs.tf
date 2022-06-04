output "account_id" {
  value = local.account_id
}

output "region" {
  value = local.region_name
}

output "id" {
  value = aws_ec2_transit_gateway.this.id
}

output "route_table_id" {
  value = aws_ec2_transit_gateway_route_table.this.id
}

output "vpcs" {
  value = var.vpcs
}
