############################################################################################################
#
# Public Subnets:
# - It's required to have at least 1 public subnet in a tier
# - Public Route Table and Route for all subnets
# - Route out IGW
#
# Note:
#   lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.public_subnet_to_azs, each.value)))
#   is building the public AZ name on the fly by looking the up the AZ letter via subnet cidr then combining the AZ
#   with the region to build full AZ name (ie us-east-1b) then lookup the shortname for the full region name (ie use1b)
#
# - public_label for tags that are related to the public subnets
# - public_az_to_subnets is map of azs to public subnets list (cidrs)
# - public_subnet_to_az is a map of public subnets to az used for subnet name tagging
# - public_subnets is a set of all public subnets
# - natgw_public_az_to_bool is a map of AZs to boolean that have a NAT Gateway enabled
############################################################################################################

locals {
  public_label            = "public"
  public_az_to_subnets    = { for az, acls in local.tier.azs : az => acls.public }
  public_subnet_to_az     = { for subnet, azs in transpose(local.public_az_to_subnets) : subnet => element(azs, 0) }
  public_subnets          = toset(keys(local.public_subnet_to_az))
  natgw_public_az_to_bool = { for az, acls in local.tier.azs : az => acls.enable_natgw if acls.enable_natgw }
}

# generate single word random pet name for each public subnet's name tag
resource "random_pet" "public" {
  for_each = local.public_subnets

  length = 1
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  availability_zone       = format("%s%s", local.region_name, lookup(local.public_subnet_to_az, each.value))
  cidr_block              = each.value
  map_public_ip_on_launch = true
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s",
        upper(var.env_prefix),
        lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.public_subnet_to_az, each.value))),
        local.tier.name,
        local.public_label,
        lookup(random_pet.public, each.value).id
      )
  })

  lifecycle {
    # ignore tags because a lookup on random_pet.public is used
    ignore_changes = [tags]
  }
}

# one public route table for all public subnets across azs
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s",
        upper(var.env_prefix),
        local.region_label,
        local.tier.name,
        local.public_label,
        "all"
      )
  })
}

# one public route out through IGW for all public subnets across azs
resource "aws_route" "public_route_out" {
  destination_cidr_block = local.route_any_cidr
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this.id
}

# associate each public subnet to the shared route table
resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = lookup(aws_subnet.public, each.key).id
  route_table_id = aws_route_table.public.id

  lifecycle {
    # route_table_id is not needed here because the value
    # is not a part of the for_each iteration and therefore
    # wont trigger forcing a new resource
    ignore_changes = [subnet_id]
  }
}

#######################################################
##
## EIPs:
## - Used for NAT Gateway's Public IP
##
#######################################################

# one eip per natgw (one per az)
resource "aws_eip" "public" {
  for_each = local.natgw_public_az_to_bool

  vpc = true
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s",
        upper(var.env_prefix),
        lookup(var.region_az_labels, format("%s%s", local.region_name, each.key)),
        local.tier.name,
        local.public_label
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
resource "aws_nat_gateway" "public" {
  for_each = local.natgw_public_az_to_bool

  allocation_id = lookup(aws_eip.public, each.key).id
  subnet_id     = lookup(aws_subnet.public, lookup(local.public_az_to_single_subnet, each.key)).id
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s",
        upper(var.env_prefix),
        lookup(var.region_az_labels, format("%s%s", local.region_name, each.key)),
        local.tier.name,
        local.public_label
      )
  })

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    ignore_changes = [allocation_id, subnet_id]
  }
}
