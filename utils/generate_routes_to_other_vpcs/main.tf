# generate routes to other VPC networks in private and public route tables for each VPC
locals {
  # { vpc-1-network => [ "vpc-1-private-rtb-id-1", "vpc-1-public-rtb-id-1", ... ], ...}
  vpc_network_to_private_and_public_route_table_ids = {
    for vpc_name, this in var.vpcs :
    this.network => concat(values(this.az_to_private_route_table_id), values(this.az_to_public_route_table_id))
  }

  # [ { rtb_id = "vpc-1-rtb-id-123", other_networks = [ "other-vpc-2-network", "other-vpc3-network", ... ] }, ...]
  associate_private_and_public_route_table_ids_with_other_networks = flatten(
    [for network, route_table_ids in local.vpc_network_to_private_and_public_route_table_ids :
      [for route_table_id in route_table_ids : {
        route_table_id = route_table_id
        other_networks = [for n in keys(local.vpc_network_to_private_and_public_route_table_ids) : n if n != network]
  }]])

  # deprecated loco legacy style
  # { rtb-id|route => route, ... }
  routes_legacy = merge(
    [for r in local.associate_private_and_public_route_table_ids_with_other_networks :
      { for route_table_id_and_network in setproduct([r.route_table_id], r.other_networks) :
        format("%s|%s", route_table_id_and_network[0], route_table_id_and_network[1]) => route_table_id_and_network[1] # each key must be unique, dont group by key
  }]...)

  # the better way to serve routes like hotcakes
  # { route_table_id = "rtb-12345678", destination_cidr_block = "x.x.x.x/x" }
  # need extra toset because there will be dupes per AZ after the flatten call
  routes = toset(flatten(
    [for r in local.associate_private_and_public_route_table_ids_with_other_networks :
      [for route_table_id_and_network in setproduct([r.route_table_id], r.other_networks) : {
        route_table_id         = route_table_id_and_network[0]
        destination_cidr_block = route_table_id_and_network[1]
  }]]))
}
