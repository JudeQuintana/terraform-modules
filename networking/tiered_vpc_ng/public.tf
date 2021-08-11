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
# - public_az_to_subnets is map of azs to public subnets (cidrs)
# - public_subnet_to_azs is a map of public subnets to azs used for subnet name tagging
# - public_subnets is a set of all public subnets
############################################################################################################

locals {
  public_label         = "public"
  public_az_to_subnets = { for az, acls in local.tier.azs : az => acls.public }
  public_subnet_to_azs = { for subnet, az in transpose(local.public_az_to_subnets) : subnet => element(az, 0) }
  public_subnets       = toset(keys(local.public_subnet_to_azs))
}

# generate single word random pet name for each public subnet's name tag
resource "random_pet" "public" {
  for_each = local.public_subnets

  length = 1
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  availability_zone       = format("%s%s", local.region_name, lookup(local.public_subnet_to_azs, each.value))
  cidr_block              = each.value
  map_public_ip_on_launch = true
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s-%s-%s",
        upper(var.env_prefix),
        lookup(var.region_az_labels, format("%s%s", local.region_name, lookup(local.public_subnet_to_azs, each.value))),
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
