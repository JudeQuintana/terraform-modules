# Pull caller identity data from provider
data "aws_caller_identity" "this" {}

# Pull region data from provider
data "aws_region" "this" {}

locals {
  account_id   = data.aws_caller_identity.this.account_id
  region_name  = data.aws_region.this.name
  region_label = lookup(var.region_az_labels, local.region_name)
}
