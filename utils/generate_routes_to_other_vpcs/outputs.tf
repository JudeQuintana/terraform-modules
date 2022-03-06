# im using call to treat this module/object as a function with no resources.
# call output is { "rtb-id|route" => "route", ... }
# route resource consumers need the first element from a split on the key with the pipe character "|" to get the route table id.
# its more of a shortcut with a consequence that the consumer needs to how to handle the data (ie split on the key).
# i could build an object here instead with the splitting which would remove the need for the consumer to do it but its another layer of iteration.
# and the route resource only needs two types of data for my case.
# there are several ways to do this so having the tests makes it easier to refactor.
#
# for example:
#
# resource "aws_route" "this" {
#   for_each = module.generate_routes_to_other_vpcs.call
#
#   destination_cidr_block = each.value
#   route_table_id         = split("|", each.key)[0]
#   transit_gateway_id     = aws_ec2_transit_gateway.this.id
# }
output "call" {
  value = local.private_and_public_routes_to_other_networks
}
