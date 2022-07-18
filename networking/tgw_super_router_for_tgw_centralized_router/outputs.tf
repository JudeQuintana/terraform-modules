output "id" {
  value = aws_ec2_transit_gateway.this_local.id
}

output "name" {
  value = local.super_router_name
}

output "networks" {
  value = concat(local.local_tgws_all_vpc_networks, local.peer_tgws_all_vpc_networks)
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
