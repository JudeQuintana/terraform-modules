# Pull region data and account id from provider
data "aws_region" "local" {
  provider = aws.local
}

data "aws_caller_identity" "local" {
  provider = aws.local
}

locals {
  local_account_id   = data.aws_caller_identity.local.account_id
  local_region_name  = data.aws_region.local.name
  local_region_label = lookup(var.region_az_labels, local.local_region_name)
  upper_env_prefix   = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)
}

# generate single word random pet name for tgw
resource "random_pet" "this" {
  length = 1
}

# one tgw that will route between all centralized routers.
resource "aws_ec2_transit_gateway" "local_this" {
  provider = aws.local

  amazon_side_asn                 = var.local_amazon_side_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = merge(
    local.default_tags,
    {
      Name = format("%s-%s-%s-%s", local.upper_env_prefix, "super-router", random_pet.this.id, local.local_region_label)
  })
}

#TODO
# figure out routing between tgws
# add routes to each vpc, use generate_routes_to_other_vpcs module??
# figure out tgw route overrides
# whatever else comes up
