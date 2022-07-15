# { "rtb-id|route" => "route", ... }
output "call" {
  # deprecate soon, probably need distinct(keys(local.private_and_public_routes_to_other_networks)) # ugly but allows for multi az
  value = local.private_and_public_routes_to_other_networks
}
# output routes as set of objects instead of a map
# { rtb_id = "rtb-1234", route = "x.x.x.x/x" }
output "call_routes" {
  value = toset(local.routes)
}

