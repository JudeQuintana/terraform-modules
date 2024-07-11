############################################################################################################
#
# - Private Subnets can have a special = true attribute set
#   - for vpc attachment use when this module is passed to Centralized Router
# - Private Route Tables are per AZ
#
# If NATGWs are enabled for an AZ:
#   - are updated to route out the NATGW to the internet
#
# Note:
#   lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.private_subnet_to_azs, each.value)))
#   is building the private AZ name on the fly by looking the up the AZ letter via subnet cidr then combining the AZ
#   with the region to build full AZ name (ie us-east-1b) then lookup the shortname for the full region name (ie use1b)
#
############################################################################################################

locals {
  private_label                      = "private"
  private_subnet_cidrs               = toset(flatten([for this in var.tiered_vpc.azs : this.private_subnets[*].cidr]))
  private_az_to_subnet_cidrs         = { for az, this in var.tiered_vpc.azs : az => this.private_subnets[*].cidr if length(this.private_subnets) > 0 }
  private_subnet_cidr_to_az          = { for subnet_cidr, azs in transpose(local.private_az_to_subnet_cidrs) : subnet_cidr => element(azs, 0) }
  private_subnet_cidr_to_subnet_name = merge([for this in var.tiered_vpc.azs : zipmap(this.private_subnets[*].cidr, this.private_subnets[*].name)]...)
  private_az_to_special_subnet_cidr  = merge([for az, this in var.tiered_vpc.azs : { for private_subnet in this.private_subnets : az => private_subnet.cidr if private_subnet.special }]...)

  #ipv6 dual stack
  private_ipv6_subnet_cidrs               = toset(flatten([for this in var.tiered_vpc.azs : compact(this.private_subnets[*].ipv6_cidr)]))
  private_ipv6_azs_with_eigw              = toset([for az, this in var.tiered_vpc.azs : az if this.eigw])
  private_ipv6_any_eigw_enabled           = length(local.private_ipv6_azs_with_eigw) > 0
  private_subnet_cidr_to_ipv6_subnet_cidr = merge([for this in var.tiered_vpc.azs : zipmap(this.private_subnets[*].cidr, this.private_subnets[*].ipv6_cidr)]...)
}

resource "aws_subnet" "this_private" {
  for_each = local.private_subnet_cidrs

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
        lookup(local.private_subnet_cidr_to_subnet_name, each.key),
        lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.private_subnet_cidr_to_az, each.key)))
      )
  })

  # private subnet could be a secondary cidr so need to wait for secondary network cidr
  depends_on = [aws_vpc_ipv4_cidr_block_association.this]
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
  for_each = local.public_natgw_az_to_subnet_cidr

  destination_cidr_block = local.route_any_cidr
  route_table_id         = lookup(aws_route_table.this_private, each.key).id
  nat_gateway_id         = lookup(aws_nat_gateway.this_public, each.key).id
}

# associate each private subnet to its respective AZ's route table
resource "aws_route_table_association" "this_private" {
  for_each = local.private_subnet_cidrs

  subnet_id      = lookup(aws_subnet.this_private, each.key).id
  route_table_id = lookup(aws_route_table.this_private, lookup(local.private_subnet_cidr_to_az, each.key)).id
}

# ipv6 dual stack
# private ipv6 subnets route out through egress only internet gateway
# subnet id is already associated to the shared public route table via aws_subnet.this_private
resource "aws_route" "this_private_ipv6_route_out" {
  for_each = local.private_ipv6_azs_with_eigw

  destination_ipv6_cidr_block = local.route_any_ipv6_cidr
  route_table_id              = lookup(aws_route_table.this_private, each.key).id
  egress_only_gateway_id      = lookup(aws_egress_only_internet_gateway.this, local.private_ipv6_any_eigw_enabled).id
}

