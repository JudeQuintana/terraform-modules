############################################################################################################
#
# If NATGWs are enabled for an AZ:
# - Private Route Tables are updated to route out the NATGW to the internet
#
# Note:
#   lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.private_subnet_to_azs, each.value)))
#   is building the private AZ name on the fly by looking the up the AZ letter via subnet cidr then combining the AZ
#   with the region to build full AZ name (ie us-east-1b) then lookup the shortname for the full region name (ie use1b)
#
############################################################################################################

locals {
  private_label                      = "private"
  private_az_to_subnet_cidrs         = { for az, this in var.tiered_vpc.azs : az => this.private_subnets[*].cidr }
  private_subnet_cidr_to_az          = { for subnet_cidr, azs in transpose(local.private_az_to_subnet_cidrs) : subnet_cidr => element(azs, 0) }
  private_subnet_cidr_to_subnet_name = merge([for this in var.tiered_vpc.azs : zipmap(this.private_subnets[*].cidr, this.private_subnets[*].name)]...)

  #ipv6
  private_ipv6_subnet_cidrs                         = flatten([for this in var.tiered_vpc.azs : [for ipv6_cidr in this.private_subnets[*].ipv6_cidr : ipv6_cidr if ipv6_cidr != null]])
  any_private_ipv6_subnet_configured                = length(local.private_ipv6_subnet_cidrs) > 0
  private_subnet_cidr_to_ipv6_subnet_cidr           = merge([for this in var.tiered_vpc.azs : zipmap(this.private_subnets[*].cidr, this.private_subnets[*].ipv6_cidr)]...)
  private_ipv6_subnet_cidr_to_subnet_cidr           = merge([for this in var.tiered_vpc.azs : { for subnet in this.private_subnets : subnet.ipv6_cdir => subnet.cidr if lookup(local.private_subnet_cidr_to_ipv6_subnet_cidr, subnet.cidr) != null }]...)
  private_route_out_ipv6_subnet_cidr_to_subnet_cidr = { for ipv6_subnet_cidr, subnet_cidr in local.private_ipv6_subnet_cidr_to_subnet_cidr : ipv6_subnet_cidr => subnet_cidr if local.any_private_ipv6_subnet_configured && var.tiered_vpc.tiered_vpc.enable_egress_only_igw }
}

resource "aws_subnet" "this_private" {
  for_each = local.private_subnet_cidr_to_subnet_name

  vpc_id                  = aws_vpc.this.id
  availability_zone       = format("%s%s", local.region_name, lookup(local.private_subnet_cidr_to_az, each.key))
  cidr_block              = each.key
  ipv6_cidr_block         = lookup(local.private_subnet_cidr_to_ipv6_subnet_cidr, each.key)
  map_public_ip_on_launch = false
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s",
        local.upper_env_prefix,
        var.tiered_vpc.name,
        local.private_label,
        each.value,
        lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.private_subnet_cidr_to_az, each.key)))
      )
  })
}

# one private route table per az
resource "aws_route_table" "this_private" {
  for_each = local.private_az_to_subnet_cidrs

  vpc_id = aws_vpc.this.id
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s",
        local.upper_env_prefix,
        var.tiered_vpc.name,
        local.private_label,
        lookup(var.region_az_labels, format("%s%s", local.region_name, each.key))
      )
  })
}

# one private route out through natgw per az
# uses a map from public.tf but the route is a
# private conext
resource "aws_route" "this_private_route_out" {
  for_each = local.public_natgw_az_to_special_subnet_cidr

  destination_cidr_block = local.route_any_cidr
  route_table_id         = lookup(aws_route_table.this_private, each.key).id
  nat_gateway_id         = lookup(aws_nat_gateway.this_public, each.key).id
}

# associate each private subnet to its respective AZ's route table
resource "aws_route_table_association" "this_private" {
  for_each = local.private_subnet_cidr_to_subnet_name

  subnet_id      = lookup(aws_subnet.this_private, each.key).id
  route_table_id = lookup(aws_route_table.this_private, lookup(local.private_subnet_cidr_to_az, each.key)).id
}

# ipv6
# private ipv6 subnets route out through egress only internet gateway if egress only igw is enabled
# subnet id is already associated to the shared public route table via aws_subnet.this_private
resource "aws_route" "this_private_ipv6_route_out" {
  for_each = local.private_route_out_ipv6_subnet_cidr_to_subnet_cidr

  destination_cidr_block = local.route_any_ipv6_cidr
  route_table_id         = lookup(aws_route_table.this_private, each.value).id
  egress_only_gateway_id = lookup(aws_egress_only_internet_gateway.this, "true").id
}

