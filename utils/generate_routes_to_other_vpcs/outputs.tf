# deprecated
# { "rtb-id|route" => "route", ... }
output "call_legacy" {
  value = local.private_and_public_routes_to_other_networks
}

# output routes as set of objects instead of a map (legacy)
# which makes it easier to handle when passing to other resources
# { route_table_id = "rtb-12345678", destination_cidr_block = "x.x.x.x/x" }
output "call" {
  value = local.routes
}
