# generate routes to other VPC networks in private and public route tables for each VPC
locals {
  # { vpc-1-network => [ "vpc-1-private-rtb-id-1", "vpc-1-public-rtb-id-1", ... ], ...}
  vpc_network_to_private_and_public_route_table_ids = {
    for vpc_name, this in var.vpcs :
    this.network => concat(values(this.az_to_private_route_table_id), values(this.az_to_public_route_table_id))
  }

  # [ { rtb_id = "vpc-1-rtb-id-123", other_networks = [ "other-vpc-2-network", "other-vpc3-network", ... ] }, ...]
  associate_private_and_public_route_table_ids_with_other_networks = flatten(
    [for network, rtb_ids in local.vpc_network_to_private_and_public_route_table_ids :
      [for rtb_id in rtb_ids : {
        rtb_id         = rtb_id
        other_networks = [for n in keys(local.vpc_network_to_private_and_public_route_table_ids) : n if n != network]
  }]])

  # { rtb-id|route => route, ... }
  private_and_public_routes_to_other_networks = merge(
    [for r in local.associate_private_and_public_route_table_ids_with_other_networks :
      { for rtb_id_and_route in setproduct([r.rtb_id], r.other_networks) :
        format("%s|%s", rtb_id_and_route[0], rtb_id_and_route[1]) => rtb_id_and_route[1] # each key must be unique, dont group by key
  }]...)
}
