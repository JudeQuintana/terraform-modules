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

#locals {
#routes_to_other_networks = merge(
#[for r in local.associate_private_and_public_route_table_ids_with_other_networks :
#{ for rtb_id_and_route in setproduct([r.rtb_id], r.other_networks) :
#rtb_id_and_route[0] => rtb_id_and_route[1]... #group by key
#}]...)

#}

output "vpcs" {
  value = { for vpc_name, this in var.vpcs : vpc_name => {
    az_to_public_route_table_id  = this.az_to_public_route_table_id
    az_to_private_route_table_id = this.az_to_private_route_table_id
    network                      = this.network
    #routes                       = local.private_and_public_routes_to_other_networks
  } }
}
