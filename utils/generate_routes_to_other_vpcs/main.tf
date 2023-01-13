# generate routes to other VPC network_cidrs in private and public route tables for each VPC
locals {
  # { vpc-1-network_cidr => [ "vpc-1-private-rtb-id-1", "vpc-1-public-rtb-id-1", ... ], ...}
  vpc_network_cidr_to_private_and_public_route_table_ids = {
    for this in var.vpcs :
    this.network_cidr => concat(values(this.az_to_private_route_table_id), values(this.az_to_public_route_table_id))
  }

  # [ { rtb_id = "vpc-1-rtb-id-123", other_network_cidrs = [ "other-vpc-2-network_cidr", "other-vpc3-network_cidr", ... ] }, ...]
  associate_private_and_public_route_table_ids_with_other_network_cidrs = flatten(
    [for network_cidr, route_table_ids in local.vpc_network_cidr_to_private_and_public_route_table_ids :
      [for this in route_table_ids : {
        route_table_id      = this
        other_network_cidrs = [for n in keys(local.vpc_network_cidr_to_private_and_public_route_table_ids) : n if n != network_cidr]
  }]])

  # deprecated loco legacy style
  # { route-table-id|route => route, ... }
  routes_legacy = merge(
    [for this in local.associate_private_and_public_route_table_ids_with_other_network_cidrs :
      { for route_table_id_and_network_cidr in setproduct([this.route_table_id], this.other_network_cidrs) :
        format("%s|%s", route_table_id_and_network_cidr[0], route_table_id_and_network_cidr[1]) => route_table_id_and_network_cidr[1] # each key must be unique, dont group by key
  }]...)

  # the better way to serve routes like hotcakes
  # { route_table_id = "rtb-12345678", destination_cidr_block = "x.x.x.x/x" }
  # need extra toset because there will be dupes per AZ after the flatten call
  routes = toset(flatten(
    [for this in local.associate_private_and_public_route_table_ids_with_other_network_cidrs :
      [for route_table_id_and_network_cidr in setproduct([this.route_table_id], this.other_network_cidrs) : {
        route_table_id         = route_table_id_and_network_cidr[0]
        destination_cidr_block = route_table_id_and_network_cidr[1]
  }]]))
}
