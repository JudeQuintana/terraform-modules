locals {
  isolated_label                      = "isolated"
  isolated_subnet_cidrs               = toset(flatten([for az, this in var.tiered_vpc.azs : this.isolated_subnets[*].cidr]))
  isolated_any_subnet_exists          = length(local.isolated_subnet_cidrs) > 0
  isolated_route_table                = { for this in [local.isolated_any_subnet_exists] : this => this if local.isolated_any_subnet_exists }
  isolated_az_to_subnet_cidrs         = { for az, this in var.tiered_vpc.azs : az => this.isolated_subnets[*].cidr }
  isolated_subnet_cidr_to_az          = { for subnet_cidr, azs in transpose(local.isolated_az_to_subnet_cidrs) : subnet_cidr => element(azs, 0) }
  isolated_subnet_cidr_to_subnet_name = merge([for this in var.tiered_vpc.azs : zipmap(this.isolated_subnets[*].cidr, this.isolated_subnets[*].name)]...)

  # isolated ipv6 dual stack subnets
  isolated_ipv6_subnet_cidrs               = toset(flatten([for az, this in var.tiered_vpc.azs : compact(this.isolated_subnets[*].ipv6_cidr)]))
  isolated_subnet_cidr_to_ipv6_subnet_cidr = merge([for this in var.tiered_vpc.azs : zipmap(this.isolated_subnets[*].cidr, this.isolated_subnets[*].ipv6_cidr)]...)
}

# isolated subnets are technically private subnets
resource "aws_subnet" "this_isolated" {
  for_each = local.isolated_subnet_cidrs

  vpc_id                  = aws_vpc.this.id
  availability_zone       = format("%s%s", local.region_name, lookup(local.isolated_subnet_cidr_to_az, each.key))
  cidr_block              = each.key
  ipv6_cidr_block         = lookup(local.isolated_subnet_cidr_to_ipv6_subnet_cidr, each.key)
  map_public_ip_on_launch = false
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s",
        local.upper_env_prefix,
        var.tiered_vpc.name,
        local.isolated_label,
        lookup(local.isolated_subnet_cidr_to_subnet_name, each.key),
        lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.isolated_subnet_cidr_to_az, each.key)))
      )
  })

  # isolated subnets could be a secondary ipv4 or ipv6 cidr so need to wait for main secondaries
  depends_on = [aws_vpc_ipv4_cidr_block_association.this, aws_vpc_ipv6_cidr_block_association.this]
}

# isolated subnets route table is intentionally empty
# they can only communicate with other subnets within the vpc
# which is consistent behvaior even when the vpc is in a full mesh tgw configuration
resource "aws_route_table" "this_isolated" {
  for_each = local.isolated_route_table

  vpc_id = aws_vpc.this.id
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s",
        local.upper_env_prefix,
        var.tiered_vpc.name,
        local.isolated_label,
        "all",
        local.region_label
      )
  })
}

resource "aws_route_table_association" "this_isolated" {
  for_each = local.isolated_subnet_cidrs

  subnet_id      = lookup(aws_subnet.this_isolated, each.key).id
  route_table_id = lookup(aws_route_table.this_isolated, local.isolated_any_subnet_exists).id
}

