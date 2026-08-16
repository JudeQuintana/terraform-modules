# output routes as set of objects instead of a map
# it makes it easier to handle when passing to other route resource types (vpc, tgw)
# toset([{ route_table_id = "rtb-12345678", destination_cidr_block = "x.x.x.x/x" }, ...])
output "ipv4" {
  value = local.routes
}

output "ipv6" {
  value = local.ipv6_routes
}
