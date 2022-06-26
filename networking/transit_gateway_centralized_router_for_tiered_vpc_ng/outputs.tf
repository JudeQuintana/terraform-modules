output "account_id" {
  value = local.account_id
}

output "region" {
  value = local.region_name
}

locals {
  tgw_id = aws_ec2_transit_gateway.this.id
}

output "id" {
  value = local.tgw_id
  #value = aws_ec2_transit_gateway.this.id
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

#output "routes" {
#value = module.generate_routes_to_other_vpcs.call_routes
#}

# vpc routes, rename later
output "routes" {
  value = [
    for this in module.generate_routes_to_other_vpcs.call_routes :
    merge(this, { tgw_id = local.tgw_id })
  ]
}
