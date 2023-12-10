output "account_id" {
  value = local.account_id
}

output "amazon_side_asn" {
  value = var.centralized_router.amazon_side_asn
}

output "blackhole_cidrs" {
  value = local.blackhole_cidrs
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
  # vpc.routes list of objects will only have 3 attributes (per object) instead of all attributes from the route
  # makes it easier to see when troubleshooting many vpc routes
  # otherwise it can just be [for this in aws_route.this_vpc_routes_to_other_vpcs : this]
  value = {
    names         = [for this in var.centralized_router.vpcs : this.name]
    network_cidrs = [for this in var.centralized_router.vpcs : this.network_cidr]
    routes = [
      for this in aws_route.this_vpc_routes_to_other_vpcs : {
        route_table_id         = this.route_table_id
        destination_cidr_block = this.destination_cidr_block
        transit_gateway_id     = this.transit_gateway_id
    }]
  }
}
