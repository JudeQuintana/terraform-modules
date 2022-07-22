# deprecated
# { "rtb-id|route" => "route", ... }
output "call_legacy" {
  value = local.routes_legacy
}

# output routes as set of objects instead of a map
# it makes it easier to handle when passing to other route resource types (vpc, tgw)
# { route_table_id = "rtb-12345678", destination_cidr_block = "x.x.x.x/x" }
output "call" {
  value = local.routes
}
