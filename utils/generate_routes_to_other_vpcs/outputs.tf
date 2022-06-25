# { "rtb-id|route" => "route", ... }
output "call" {
  value = local.private_and_public_routes_to_other_networks
}
# output routes as list of objects instead of a map
# { rtb_id = "rtb-1234", route = "x.x.x.x/x" }
output "call_routes" {
  value = local.routes
}
