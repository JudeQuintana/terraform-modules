############################################################################################################
#
# - Public Subnets can have a special = true attribute set
#   - for vpc attachment use when this module is passed to Centralized Router
# - One Public Route Table shared by all public subnets
# - IGW which now auto toggles based on if any public subnet exists
#
# If NATGWs are enabled for an AZ:
# - NATGW is created in the public subnet with natgw = true for each AZ
# - EIP is created and associated to the NATGW
#
# Note:
#   lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.public_subnet_to_azs, each.value)))
#   is building the public AZ name on the fly by looking the up the AZ letter via subnet cidr then combining the AZ
#   with the region to build full AZ name (ie us-east-1b) then lookup the shortname for the full region name (ie use1b)
#
############################################################################################################

locals {
  public_label                      = "public"
  public_subnet_cidrs               = toset(flatten([for this in var.tiered_vpc.azs : this.public_subnets[*].cidr]))
  public_any_subnet_exists          = length(local.public_subnet_cidrs) > 0
  public_az_to_subnet_cidrs         = { for az, this in var.tiered_vpc.azs : az => this.public_subnets[*].cidr if length(this.public_subnets) > 0 }
  public_subnet_cidr_to_az          = { for subnet_cidr, azs in transpose(local.public_az_to_subnet_cidrs) : subnet_cidr => element(azs, 0) }
  public_subnet_cidr_to_subnet_name = merge([for this in var.tiered_vpc.azs : zipmap(this.public_subnets[*].cidr, this.public_subnets[*].name)]...)
  public_az_to_special_subnet_cidr  = merge([for az, this in var.tiered_vpc.azs : { for public_subnet in this.public_subnets : az => public_subnet.cidr if public_subnet.special }]...)
  public_natgw_az_to_subnet_cidr    = merge([for az, this in var.tiered_vpc.azs : { for public_subnet in this.public_subnets : az => public_subnet.cidr if public_subnet.natgw }]...)

  # ipv6 dual stack
  public_ipv6_subnet_cidrs               = toset(flatten([for this in var.tiered_vpc.azs : compact(this.public_subnets[*].ipv6_cidr)]))
  public_subnet_cidr_to_ipv6_subnet_cidr = merge([for this in var.tiered_vpc.azs : zipmap(this.public_subnets[*].cidr, this.public_subnets[*].ipv6_cidr)]...)
}

resource "aws_subnet" "this_public" {
  for_each = local.public_subnet_cidrs

  vpc_id                  = aws_vpc.this.id
  availability_zone       = format("%s%s", local.region_name, lookup(local.public_subnet_cidr_to_az, each.key))
  cidr_block              = each.key
  ipv6_cidr_block         = lookup(local.public_subnet_cidr_to_ipv6_subnet_cidr, each.key)
  map_public_ip_on_launch = true
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s",
        upper(var.env_prefix),
        var.tiered_vpc.name,
        local.public_label,
        lookup(local.public_subnet_cidr_to_subnet_name, each.key),
        lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.public_subnet_cidr_to_az, each.key)))
      )
  })

  # public subnet could be a secondary ipv4 or ipv6 cidr so need to wait for main secondaries
  depends_on = [aws_vpc_ipv4_cidr_block_association.this, aws_vpc_ipv6_cidr_block_association.this]
}

# one public route table for all public subnets across azs
resource "aws_route_table" "this_public" {
  for_each = local.igw

  vpc_id = aws_vpc.this.id
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s",
        upper(var.env_prefix),
        var.tiered_vpc.name,
        local.public_label,
        "all",
        local.region_label
      )
  })
}

# one public route out through IGW for all public subnets across azs if an igw exists
# igw will exists if public subnet exists
resource "aws_route" "this_public_route_out" {
  for_each = local.igw

  destination_cidr_block = local.route_any_cidr
  route_table_id         = lookup(aws_route_table.this_public, each.key).id
  gateway_id             = lookup(aws_internet_gateway.this, each.key).id
}

# associate each public subnet to the shared route table
resource "aws_route_table_association" "this_public" {
  for_each = local.public_subnet_cidrs

  subnet_id      = lookup(aws_subnet.this_public, each.key).id
  route_table_id = lookup(aws_route_table.this_public, local.public_any_subnet_exists).id
}

# one eip per natgw (one per az)
resource "aws_eip" "this_public" {
  for_each = local.public_natgw_az_to_subnet_cidr

  domain = "vpc"
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s",
        local.upper_env_prefix,
        var.tiered_vpc.name,
        local.public_label,
        lookup(var.region_az_labels, format("%s%s", local.region_name, each.key))
      )
  })
}

# only one natgw per AZ if enabled
resource "aws_nat_gateway" "this_public" {
  for_each = local.public_natgw_az_to_subnet_cidr

  allocation_id = lookup(aws_eip.this_public, each.key).id
  subnet_id     = lookup(aws_subnet.this_public, each.value).id
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s",
        local.upper_env_prefix,
        var.tiered_vpc.name,
        local.public_label,
        lookup(var.region_az_labels, format("%s%s", local.region_name, each.key))
      )
  })

  depends_on = [aws_internet_gateway.this]
}

# ipv6 dual stack
# one public route out through IGW for all public ipv6 subnets across azs
# subnet id is already associated to the shared public route table via aws_subnet.this_public
resource "aws_route" "this_public_ipv6_route_out" {
  for_each = local.igw

  destination_ipv6_cidr_block = local.route_any_ipv6_cidr
  route_table_id              = lookup(aws_route_table.this_public, each.key).id
  gateway_id                  = lookup(aws_internet_gateway.this, each.key).id
}

