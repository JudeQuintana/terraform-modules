locals {
  # route_table_id -> vpc name (reverse lookup)
  route_table_to_vpc_name = merge([
    for name, vpc in var.vpcs : {
      for route_table_id in concat(vpc.private_route_table_ids, vpc.public_route_table_ids) :
      route_table_id => name
    }
  ]...)

  # any cidr (primary or secondary) -> vpc name
  any_cidr_to_vpc_name = merge([
    for name, vpc in var.vpcs : {
      for cidr in concat([vpc.network_cidr], vpc.secondary_cidrs) :
      cidr => name
    }
  ]...)

  # route provenance: for each emitted route, trace back to source pair and verdict
  unknown = "unknown"
  provenance = {
    for route in local.routes :
    format("%s|%s", route.route_table_id, route.destination_cidr_block) => format(
      "%s -> %s (%s)",
      lookup(local.route_table_to_vpc_name, route.route_table_id, local.unknown),
      lookup(local.any_cidr_to_vpc_name, route.destination_cidr_block, local.unknown),
      lookup(
        local.reachability,
        format("%s:%s",
          lookup(local.route_table_to_vpc_name, route.route_table_id, local.unknown),
          lookup(local.any_cidr_to_vpc_name, route.destination_cidr_block, local.unknown)
        ),
        local.unknown
      )
    )
  }
}
