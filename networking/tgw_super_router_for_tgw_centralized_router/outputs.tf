output "name" {
  value = var.super_router.name
}

output "blackhole_subnets" {
  value = var.super_router.blackhole_subnets
}

output "local" {
  value = {
    account_id      = local.local_account_id
    amazon_side_asn = var.super_router.local.amazon_side_asn
    full_name       = local.local_super_router_name
    id              = aws_ec2_transit_gateway.this_local.id
    networks        = local.local_tgws_all_vpc_networks
    region          = local.local_region_name
    route_table_id  = aws_ec2_transit_gateway_route_table.this_local.id
  }
}

output "peer" {
  value = {
    account_id      = local.peer_account_id
    amazon_side_asn = var.super_router.peer.amazon_side_asn
    full_name       = local.peer_super_router_name
    id              = aws_ec2_transit_gateway.this_peer.id
    networks        = local.peer_tgws_all_vpc_networks
    region          = local.peer_region_name
    route_table_id  = aws_ec2_transit_gateway_route_table.this_peer.id
  }
}
