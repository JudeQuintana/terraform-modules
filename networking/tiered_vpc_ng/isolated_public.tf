locals {
  # isolated public subnets
  public_isolated_subnet_cidrs               = toset(flatten([for az, this in var.tiered_vpc.azs : this.isolated_public_subnets[*].cidr]))
  public_any_isolated_subnet_exists          = length(local.public_isolated_subnet_cidrs) > 0
  public_isolated_route_table                = { for this in [local.public_any_isolated_subnet_exists] : this => this if local.public_any_isolated_subnet_exists }
  public_az_to_isolated_subnet_cidrs         = { for az, this in var.tiered_vpc.azs : az => this.isolated_public_subnets[*].cidr if length(this.isolated_public_subnets) > 0 }
  public_isolated_subnet_cidr_to_az          = { for subnet_cidr, azs in transpose(local.public_az_to_isolated_subnet_cidrs) : subnet_cidr => element(azs, 0) }
  public_isolated_subnet_cidr_to_subnet_name = merge([for this in var.tiered_vpc.azs : zipmap(this.isolated_public_subnets[*].cidr, this.isolated_public_subnets[*].name)]...)

  # ipv6 isolated_public_subnets
  public_isolated_ipv6_subnet_cidrs                        = toset(flatten([for az, this in var.tiered_vpc.azs : compact(this.isolated_public_subnets[*].ipv6_cidr)]))
  public_any_isolated_ipv6_subnet_exists                   = length(local.public_isolated_ipv6_subnet_cidrs) > 0
  public_isolated_subnet_cidr_to_isolated_ipv6_subnet_cidr = merge([for this in var.tiered_vpc.azs : zipmap(this.public_subnets[*].cidr, this.public_subnets[*].ipv6_cidr)]...)
}

resource "aws_subnet" "this_public_isolated" {
  for_each = local.public_isolated_subnet_cidrs

  vpc_id                  = aws_vpc.this.id
  availability_zone       = format("%s%s", local.region_name, lookup(local.public_isolated_subnet_cidr_to_az, each.key))
  cidr_block              = each.key
  ipv6_cidr_block         = lookup(local.public_isolated_subnet_cidr_to_isolated_ipv6_subnet_cidr, each.key)
  map_public_ip_on_launch = true
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s-%s",
        upper(var.env_prefix),
        var.tiered_vpc.name,
        "isolated",
        local.public_label,
        lookup(local.public_isolated_subnet_cidr_to_subnet_name, each.key),
        lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.public_isolated_subnet_cidr_to_az, each.key)))
      )
  })

  depends_on = [aws_subnet.this_public]
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

  subnet_id      = lookup(aws_subnet.this_public_isolated, each.key).id
  route_table_id = lookup(aws_route_table.this_public_isolated, local.public_any_isolated_subnet_exists).id
}
