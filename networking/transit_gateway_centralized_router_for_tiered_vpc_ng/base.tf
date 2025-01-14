# Pull caller identity data from provider
data "aws_caller_identity" "this" {}

# Pull region data from provider
data "aws_region" "this" {}

locals {
  account_id       = data.aws_caller_identity.this.account_id
  region_name      = data.aws_region.this.name
  region_label     = lookup(var.region_az_labels, local.region_name)
  upper_env_prefix = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)

  centralized_router_name = format("%s-%s-%s-%s", local.upper_env_prefix, "centralized-router", var.centralized_router.name, local.region_label)

  # add the vpc and it's azs the to the mesh if there's 1 or more AZs with special = true
  # if there are no AZs with special = true then the VPC is fully removed from the mesh (vpc and tgw routes)
  # making it easier to decomission AZs and VPCs without manual intervention
  vpcs = {
    for this in var.centralized_router.vpcs :
    this.id => this
    if length(concat(this.private_special_subnet_ids, this.public_special_subnet_ids)) > 0
  }
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
      condition     = alltrue([for this in local.vpcs : contains([local.region_name], this.region)])
      error_message = "All VPC regions must match the aws provider region for Centralized Router."
    }

    precondition {
      condition     = alltrue([for this in local.vpcs : contains([local.account_id], this.account_id)])
      error_message = "All VPC account IDs must match the aws provider account ID for Centralized Router."
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

