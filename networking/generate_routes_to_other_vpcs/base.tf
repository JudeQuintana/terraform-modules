locals {
  network_cidrs_with_route_table_ids = [
    for this in var.vpcs : {
      network_cidrs      = concat([this.network_cidr], this.secondary_cidrs)
      ipv6_network_cidrs = concat(compact([this.ipv6_network_cidr]), this.ipv6_secondary_cidrs)
      route_table_ids    = concat(this.private_route_table_ids, this.public_route_table_ids)
    }
  ]

  # ipv4
  associated_route_table_ids_with_other_network_cidrs = flatten([
    for this in local.network_cidrs_with_route_table_ids : [
      for route_table_id in this.route_table_ids : {
        route_table_id      = route_table_id
        other_network_cidrs = lookup(local.network_cidr_to_other_network_cidrs, element(this.network_cidrs, 0), [])
  }]])

  # the better way to serve routes like hotcakes
  # [{ route_table_id = "rtb-12345678", destination_cidr_block = "x.x.x.x/x" }...]
  routes = toset(flatten([
    for this in local.associated_route_table_ids_with_other_network_cidrs : [
      for pair in setproduct([this.route_table_id], this.other_network_cidrs) : {
        route_table_id         = pair[0]
        destination_cidr_block = pair[1]
  }]]))

  # ipv6
  associated_route_table_ids_with_other_ipv6_network_cidrs = flatten([
    for this in local.network_cidrs_with_route_table_ids : [
      for route_table_id in this.route_table_ids : {
        route_table_id           = route_table_id
        other_ipv6_network_cidrs = lookup(local.ipv6_network_cidr_to_other_ipv6_network_cidrs, element(this.ipv6_network_cidrs, 0), [])
  }] if length(this.ipv6_network_cidrs) > 0])

  ipv6_routes = toset(flatten([
    for this in local.associated_route_table_ids_with_other_ipv6_network_cidrs : [
      for pair in setproduct([this.route_table_id], this.other_ipv6_network_cidrs) : {
        route_table_id              = pair[0]
        destination_ipv6_cidr_block = pair[1]
  }]]))
}
