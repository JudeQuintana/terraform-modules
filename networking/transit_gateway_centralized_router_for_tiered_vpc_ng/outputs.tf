output "account_id" {
  value = local.account_id
}

output "amazon_side_asn" {
  value = var.centralized_router.amazon_side_asn
}

output "blackhole_cidrs" {
  value = var.centralized_router.blackhole.cidrs
}

output "blackhole_ipv6_cidrs" {
  value = var.centralized_router.blackhole.ipv6_cidrs
}

output "full_name" {
  value = local.centralized_router_name
}

output "id" {
  value = aws_ec2_transit_gateway.this.id
}

output "name" {
  value = var.centralized_router.name
}

output "region" {
  value = local.region_name
}

output "route_table_id" {
  value = aws_ec2_transit_gateway_route_table.this.id
}

output "vpc" {
  value = {
    names                   = [for this in local.vpcs : this.name]
    network_cidrs           = [for this in local.vpcs : this.network_cidr]
    secondary_cidrs         = flatten([for this in local.vpcs : this.secondary_cidrs])
    ipv6_network_cidrs      = compact([for this in local.vpcs : this.ipv6_network_cidr])
    ipv6_secondary_cidrs    = flatten([for this in local.vpcs : this.ipv6_secondary_cidrs])
    private_route_table_ids = flatten([for this in local.vpcs : this.private_route_table_ids])
    public_route_table_ids  = flatten([for this in local.vpcs : this.public_route_table_ids])
  }
}

