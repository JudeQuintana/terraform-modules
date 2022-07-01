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

output "vpc_attachments" {
  value = [for vpc_id, this in aws_ec2_transit_gateway_vpc_attachment.this : this]
}

#output "routes" {
#value = module.generate_routes_to_other_vpcs.call_routes
#}

# vpc routes, rename later
output "routes" {
  value = [for rtb_id_route, this in aws_route.this : {
    rtb_id = this.route_table_id
    route  = this.destination_cidr_block
    tgw_id = this.transit_gateway_id
    }
  ]
}
