# isolated private subnets route table is intentionally empty
locals {
  private_isolated_route_table = { for this in [local.private_any_isolated_subnet_exists] : this => this if local.private_any_isolated_subnet_exists }
}

resource "aws_route_table" "this_private_isolated" {
  for_each = local.local_private_isolated_route_table

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

  subnet_id      = lookup(aws_subnet.this_private, each.key).id
  route_table_id = lookup(aws_route_table.this_private_isolated, lookup(local.private_subnet_cidr_to_az, each.key)).id
}

locals {
  public_isolated_route_table = { for this in [local.public_any_isolated_subnet_exists] : this => this if local.public_any_isolated_subnet_exists }
}

# isolated public subnets route table is intentionally empty
resource "aws_route_table" "this_public_isolated" {
  for_each = local.public_isolated_route_table

  vpc_id = aws_vpc.this.id
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s",
        local.upper_env_prefix,
        var.tiered_vpc.name,
        "isolated",
        local.public_label,
        lookup(var.region_az_labels, format("%s%s", local.region_name, each.key))
      )
  })
}

resource "aws_route_table_association" "this_public_isolated" {
  for_each = local.public_isolated_subnet_cidrs

  subnet_id      = lookup(aws_subnet.this_public, each.key).id
  route_table_id = lookup(aws_route_table.this_public_isolated, lookup(local.public_subnet_cidr_to_az, each.key)).id
}
