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
# - natgw_private_az_to_bool is a map of AZs to boolean that have a NAT Gateway configured and have
#   private subnets configured
############################################################################################################

locals {
  private_label            = "private"
  private_az_to_subnets    = { for az, acls in local.tier.azs : az => acls.private }
  private_subnet_to_az     = { for subnet, azs in transpose(local.private_az_to_subnets) : subnet => element(azs, 0) }
  private_subnets          = toset(keys(local.private_subnet_to_az))
  natgw_private_az_to_bool = { for az, acls in local.tier.azs : az => acls.enable_natgw if acls.enable_natgw && length(local.private_subnets) > 0 }
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
        upper(var.env_prefix),
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
        upper(var.env_prefix),
        lookup(var.region_az_labels, format("%s%s", local.region_name, each.key)),
        local.tier.name,
        local.private_label
      )
  })
}

# one private route out through natgw per az
resource "aws_route" "private_route_out" {
  for_each = local.natgw_private_az_to_bool

  destination_cidr_block = local.route_any_cidr
  route_table_id         = lookup(aws_route_table.private, each.key).id
  nat_gateway_id         = lookup(aws_nat_gateway.private, each.key).id

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

#######################################################
##
## EIPs:
## - Used for NAT Gateway's Public IP
##
#######################################################

# one eip per natgw (one per az)
resource "aws_eip" "private" {
  for_each = local.natgw_private_az_to_bool

  vpc = true
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s",
        upper(var.env_prefix),
        lookup(var.region_az_labels, format("%s%s", local.region_name, each.key)),
        local.tier.name,
        local.private_label
      )
  })
}

#######################################################
##
## NAT Gatways:
## - For routing the respective private AZ traffic and
##   is built in a public subnet
## - depends_on is required because NAT GW needs an IGW
##   to route through but there is not an implicit
##   dependency via it's attributes so we must be
##   explicit.
##
#######################################################

locals {
  # grab the first public subnet in the list per az to put a nat gateway
  public_az_to_single_subnet = { for az, subnets in local.public_az_to_subnets : az => element(subnets, 0) }
}

# one natgw per az, put natgw in a single public subnet in relative az if the natgw is enabled for a private subnet
resource "aws_nat_gateway" "private" {
  for_each = local.natgw_private_az_to_bool

  allocation_id = lookup(aws_eip.private, each.key).id
  subnet_id     = lookup(aws_subnet.public, lookup(local.public_az_to_single_subnet, each.key)).id
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s",
        upper(var.env_prefix),
        lookup(var.region_az_labels, format("%s%s", local.region_name, each.key)),
        local.tier.name,
        local.private_label
      )
  })

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    ignore_changes = [allocation_id, subnet_id]
  }
}
