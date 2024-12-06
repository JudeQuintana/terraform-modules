# isolated private subnets route table is intentionally empty
locals {
  # isolated subnets
  private_isolated_subnet_cidrs               = toset(flatten([for az, this in var.tiered_vpc.azs : this.isolated_private_subnets[*].cidr]))
  private_any_isolated_subnet_exists          = length(local.private_isolated_subnet_cidrs) > 0
  private_isolated_route_table                = { for this in [local.private_any_isolated_subnet_exists] : this => this if local.private_any_isolated_subnet_exists }
  private_az_to_isolated_subnet_cidrs         = { for az, this in var.tiered_vpc.azs : az => this.isolated_private_subnets[*].cidr if length(this.isolated_private_subnets) > 0 }
  private_isolated_subnet_cidr_to_az          = { for subnet_cidr, azs in transpose(local.private_az_to_isolated_subnet_cidrs) : subnet_cidr => element(azs, 0) }
  private_isolated_subnet_cidr_to_subnet_name = merge([for this in var.tiered_vpc.azs : zipmap(this.isolated_private_subnets[*].cidr, this.isolated_private_subnets[*].name)]...)

  # isolated ipv6 dual stack subnets
  private_isolated_ipv6_subnet_cidrs                        = toset(flatten([for az, this in var.tiered_vpc.azs : compact(this.isolated_private_subnets[*].ipv6_cidr)]))
  private_isolated_subnet_cidr_to_isolated_ipv6_subnet_cidr = merge([for this in var.tiered_vpc.azs : zipmap(this.isolated_private_subnets[*].cidr, this.isolated_private_subnets[*].ipv6_cidr)]...)
}

resource "aws_subnet" "this_private_isolated" {
  for_each = local.private_isolated_subnet_cidrs

  vpc_id                  = aws_vpc.this.id
  availability_zone       = format("%s%s", local.region_name, lookup(local.private_isolated_subnet_cidr_to_az, each.key))
  cidr_block              = each.key
  ipv6_cidr_block         = lookup(local.private_isolated_subnet_cidr_to_isolated_ipv6_subnet_cidr, each.key)
  map_public_ip_on_launch = false
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s-%s",
        local.upper_env_prefix,
        var.tiered_vpc.name,
        "isolated",
        local.private_label,
        lookup(local.private_isolated_subnet_cidr_to_subnet_name, each.key),
        lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.private_isolaed_subnet_cidr_to_az, each.key)))
      )
  })

  depends_on = [aws_subnet.this_private]
}

resource "aws_route_table" "this_private_isolated" {
  for_each = local.private_isolated_route_table

  vpc_id = aws_vpc.this.id
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s",
        local.upper_env_prefix,
        var.tiered_vpc.name,
        "isolated",
        local.private_label,
        lookup(var.region_az_labels, format("%s%s", local.region_name, each.key))
      )
  })
}

resource "aws_route_table_association" "this_private_isolated" {
  for_each = local.private_isolated_subnet_cidrs

  subnet_id      = lookup(aws_subnet.this_private_isolated, each.key).id
  route_table_id = lookup(aws_route_table.this_private_isolated, local.private_any_isolated_subnet_exists).id
}

