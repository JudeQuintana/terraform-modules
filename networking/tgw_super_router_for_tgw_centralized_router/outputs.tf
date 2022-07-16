output "id" {
  value = aws_ec2_transit_gateway.this_local.id
}

output "local_account_id" {
  value = local.local_account_id
}

output "local_region" {
  value = local.local_region_name
}

output "route_table_id" {
  value = aws_ec2_transit_gateway_route_table.this_local
}
