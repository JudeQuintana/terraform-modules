output "account_id" {
  value = local.account_id
}

output "amazon_side_asn" {
  value = var.centralized_router.amazon_side_asn
}

output "name" {
  value = var.centralized_router.name
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
  value = [for this in var.centralized_router.vpcs : this.network]
}

output "vpc_routes" {
  value = [for this in aws_route.this : this]
}

output "vpcs" {
  value = var.centralized_router.vpcs
}
