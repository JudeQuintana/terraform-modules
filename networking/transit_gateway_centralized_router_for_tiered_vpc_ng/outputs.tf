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

output "networks" {
  value = [for vpc_name, this in var.vpcs : this.network]
}

output "vpc_routes" {
  value = [for route_key, this in aws_route.this : this]
}
