# generate routes to other VPC network_cidrs, secondary_cidrs and ipv6_newtork_cidrs in private and public route tables for each VPC
locals {
  network_cidrs_with_route_table_ids = [
    for this in var.vpcs : {
      network_cidrs   = concat([this.network_cidr], this.secondary_network_cidrs, compact([this.ipv6_network_cidr]))
      route_table_ids = concat(this.private_route_table_ids, this.public_route_table_ids)
    }
  ]

  # [ { rtb_id = "vpc-1-rtb-id-123", other_network_cidrs = [ "other-vpc-2-network_cidr", "other-vpc3-network_cidr", ... ] }, ...]
  associated_route_table_ids_with_other_network_cidrs = flatten([
    for this in local.network_cidrs_with_route_table_ids : [
      for route_table_id in this.route_table_ids : {
        route_table_id      = route_table_id
        other_network_cidrs = [for n in flatten(local.network_cidrs_with_route_table_ids[*].network_cidrs) : n if !contains(this.network_cidrs, n)]
  }]])

  # the better way to serve routes like hotcakes
  # { route_table_id = "rtb-12345678", destination_cidr_block = "x.x.x.x/x" }
  # need extra toset because there will be duplicates per AZ after the flatten call
  routes = toset(flatten([
    for this in local.associated_route_table_ids_with_other_network_cidrs : [
      for route_table_id_and_network_cidr in setproduct([this.route_table_id], this.other_network_cidrs) : {
        route_table_id         = route_table_id_and_network_cidr[0]
        destination_cidr_block = route_table_id_and_network_cidr[1]
  }]]))
}
