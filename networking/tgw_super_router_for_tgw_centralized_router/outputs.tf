output "local" {
  value = {
    account_id     = local.local_account_id
    full_name      = local.local_super_router_name
    id             = aws_ec2_transit_gateway.this_local.id
    networks       = local.local_tgws_all_vpc_networks
    region         = local.local_region_name
    route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
  }
}

output "peer" {
  value = {
    account_id     = local.peer_account_id
    full_name      = local.peer_super_router_name
    id             = aws_ec2_transit_gateway.this_peer.id
    networks       = local.peer_tgws_all_vpc_networks
    region         = local.peer_region_name
    route_table_id = aws_ec2_transit_gateway_route_table.this_peer.id
  }
}
