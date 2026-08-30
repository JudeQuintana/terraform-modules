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
  value = local.centralized_router_full_name
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

output "vpcs" {
  value = {
    for this in local.vpcs :
    this.name => {
      id                      = this.id
      name                    = this.name
      full_name               = this.full_name
      network_cidr            = this.network_cidr
      secondary_cidrs         = this.secondary_cidrs
      ipv6_network_cidr       = this.ipv6_network_cidr
      ipv6_secondary_cidrs    = this.ipv6_secondary_cidrs
      private_route_table_ids = this.private_route_table_ids
      public_route_table_ids  = this.public_route_table_ids
    }
  }
}

