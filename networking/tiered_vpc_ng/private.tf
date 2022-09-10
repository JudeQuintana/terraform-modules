############################################################################################################
#
# Private Subnets with NAT Gateway:
# - Route Tables with Associtated Routes
# - Route out respective AZ NAT Gateway if enabled.
#
# Note:
#   lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.private_subnet_to_azs, each.value)))
#   is building the private AZ name on the fly by looking the up the AZ letter via subnet cidr then combining the AZ
#   with the region to build full AZ name (ie us-east-1b) then lookup the shortname for the full region name (ie use1b)
#
# - private_label for tags that are related to the private subnets
# - private_az_to_subnets is map of azs to private subnets list (cidrs)
# - private_subnet_to_az is a map of private subnets to az used for subnet name tagging
# - private_subnets is a set of all private subnets
############################################################################################################

locals {
  private_label         = "private"
  private_az_to_subnets = { for az, acls in local.tier.azs : az => acls.private }
  private_subnet_to_az  = { for subnet, azs in transpose(local.private_az_to_subnets) : subnet => element(azs, 0) }
  private_subnets       = toset(keys(local.private_subnet_to_az))
}

# generate single word random pet name for each privae subnet's name tag
resource "random_pet" "private" {
  for_each = local.private_subnets

  length = 1
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id                  = aws_vpc.this.id
  availability_zone       = format("%s%s", local.region_name, lookup(local.private_subnet_to_az, each.value))
  cidr_block              = each.value
  map_public_ip_on_launch = false
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s",
        local.upper_env_prefix,
        lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.private_subnet_to_az, each.value))),
        local.tier.name,
        local.private_label,
        lookup(random_pet.private, each.value).id
      )
  })

  lifecycle {
    # ignore tags because a lookup on random_pet.private is used
    ignore_changes = [tags]
  }
}

# one private route table per az
resource "aws_route_table" "private" {
  for_each = local.private_az_to_subnets

  vpc_id = aws_vpc.this.id
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s",
        local.upper_env_prefix,
        lookup(var.region_az_labels, format("%s%s", local.region_name, each.key)),
        local.tier.name,
        local.private_label
      )
  })
}

# one private route out through natgw per az
# uses a map from public.tf but the route is a
# private conext
resource "aws_route" "private_route_out" {
  for_each = local.natgw_public_az_to_bool

  destination_cidr_block = local.route_any_cidr
  route_table_id         = lookup(aws_route_table.private, each.key).id
  nat_gateway_id         = lookup(aws_nat_gateway.public, each.key).id

  lifecycle {
    ignore_changes = [route_table_id, nat_gateway_id]
  }
}

# associate each private subnet to its respective AZ's route table
resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = lookup(aws_subnet.private, each.key).id
  route_table_id = lookup(aws_route_table.private, lookup(local.private_subnet_to_az, each.value)).id

  lifecycle {
    ignore_changes = [subnet_id, route_table_id]
  }
}
