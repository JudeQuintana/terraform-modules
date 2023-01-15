# Pull caller identity data from provider
data "aws_caller_identity" "current" {}

# Pull region data from provider
data "aws_region" "current" {}

locals {
  account_id            = data.aws_caller_identity.current.account_id
  region_name           = data.aws_region.current.name
  region_label          = lookup(var.region_az_labels, local.region_name)
  upper_env_prefix      = upper(var.env_prefix)
  route_format          = "%s|%s"
  vpc_attachment_format = "%s <-> %s"

  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)
}

locals {
  centralized_router_name = format("%s-%s-%s-%s", local.upper_env_prefix, "centralized-router", var.centralized_router.name, local.region_label)
}

# one tgw that will route between all tiered vpcs.
resource "aws_ec2_transit_gateway" "this" {
  amazon_side_asn                 = var.centralized_router.amazon_side_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = merge(
    local.default_tags,
    { Name = local.centralized_router_name }
  )

  lifecycle {
    # preconditions are evaluated on apply only.
    precondition {
      condition     = alltrue([for this in var.centralized_router.vpcs : contains([local.region_name], this.region)])
      error_message = "All Tiered VPC regions must match the aws provider region for Centralized Router."
    }
  }
}

# one route table for all vpc network_cidrs
resource "aws_ec2_transit_gateway_route_table" "this" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags = merge(
    local.default_tags,
    { Name = local.centralized_router_name }
  )
}

