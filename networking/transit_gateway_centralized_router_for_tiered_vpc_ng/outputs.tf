output "account_id" {
  value = local.account_id
}

output "amazon_side_asn" {
  value = var.amazon_side_asn
}

output "full_name" {
  value = local.centralized_router_name
}

output "id" {
  value = aws_ec2_transit_gateway.this.id
}

output "region" {
  value = local.region_name
}

output "route_table_id" {
  value = aws_ec2_transit_gateway_route_table.this.id
}

output "vpc_networks" {
  value = [for vpc_name, this in var.vpcs : this.network]
}

output "vpc_routes" {
  value = [for route_key, this in aws_route.this : this]
}

output "vpcs" {
  value = var.vpcs
}

