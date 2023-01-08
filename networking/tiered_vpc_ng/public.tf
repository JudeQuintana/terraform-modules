############################################################################################################
#
# Public Subnets:
# - It's required to have at least 1 public subnet in a tiered vpc
# - Public Route Table and Route for all subnets
# - Route out IGW
#
# If NATGWs are enabled for an AZ:
# - NATGW is created in the first public subnet in the AZ
# - EIP is created and associated to the NATGW
#
# Note:
#   lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.public_subnet_to_azs, each.value)))
#   is building the public AZ name on the fly by looking the up the AZ letter via subnet cidr then combining the AZ
#   with the region to build full AZ name (ie us-east-1b) then lookup the shortname for the full region name (ie use1b)
#
############################################################################################################

locals {
  public_label                          = "public"
  public_az_to_subnet_cidrs             = { for az, this in var.tiered_vpc.azs : az => this.public_subnets[*].cidr }
  public_subnet_cidr_to_az              = { for subnet_cidr, azs in transpose(local.public_az_to_subnet_cidrs) : subnet_cidr => element(azs, 0) }
  public_subnet_cidr_to_subnet_name     = merge([for this in var.tiered_vpc.azs : zipmap(this.public_subnets[*].cidr, this.public_subnets[*].name)]...)
  natgw_public_az_to_public_subnet_cidr = { for az, this in var.tiered_vpc.azs : az => lookup(local.public_az_to_subnet_cidrs, az)[0] if this.enable_natgw }
}

resource "aws_subnet" "this_public" {
  for_each = local.public_subnet_cidr_to_subnet_name

  vpc_id                  = aws_vpc.this.id
  availability_zone       = format("%s%s", local.region_name, lookup(local.public_subnet_cidr_to_az, each.key))
  cidr_block              = each.key
  map_public_ip_on_launch = true
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s",
        upper(var.env_prefix),
        lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.public_subnet_cidr_to_az, each.key))),
        var.tiered_vpc.name,
        local.public_label,
        each.value
      )
  })
}

# one public route table for all public subnets across azs
resource "aws_route_table" "this_public" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s",
        upper(var.env_prefix),
        local.region_label,
        var.tiered_vpc.name,
        local.public_label,
        "all"
      )
  })
}

# one public route out through IGW for all public subnets across azs
resource "aws_route" "public_route_out" {
  destination_cidr_block = local.route_any_cidr
  route_table_id         = aws_route_table.this_public.id
  gateway_id             = aws_internet_gateway.this.id
}

# associate each public subnet to the shared route table
resource "aws_route_table_association" "this_public" {
  for_each = local.public_subnet_cidr_to_subnet_name

  subnet_id      = lookup(aws_subnet.this_public, each.key).id
  route_table_id = aws_route_table.this_public.id

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
resource "aws_eip" "this_public" {
  for_each = local.natgw_public_az_to_public_subnet_cidr

  vpc = true
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s",
        local.upper_env_prefix,
        lookup(var.region_az_labels, format("%s%s", local.region_name, each.key)),
        var.tiered_vpc.name,
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

# one natgw per az, put natgw in a single public subnet in relative az if the natgw is enabled for a private subnet
resource "aws_nat_gateway" "this_public" {
  for_each = local.natgw_public_az_to_public_subnet_cidr

  allocation_id = lookup(aws_eip.this_public, each.key).id
  subnet_id     = lookup(aws_subnet.this_public, each.value).id
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s",
        local.upper_env_prefix,
        lookup(var.region_az_labels, format("%s%s", local.region_name, each.key)),
        var.tiered_vpc.name,
        local.public_label
      )
  })

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    ignore_changes = [allocation_id, subnet_id]
  }
}
