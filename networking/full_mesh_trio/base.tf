# Pull region data and account id from provider
data "aws_caller_identity" "this_one" {
  provider = aws.one
}

data "aws_region" "this_one" {
  provider = aws.one
}

data "aws_caller_identity" "this_two" {
  provider = aws.two
}

data "aws_region" "this_two" {
  provider = aws.two
}

data "aws_caller_identity" "this_three" {
  provider = aws.three
}

data "aws_region" "this_three" {
  provider = aws.three
}

locals {
  one_provider_account_id  = data.aws_caller_identity.this_one.account_id
  one_provider_region_name = data.aws_region.this_one.name

  two_provider_account_id  = data.aws_caller_identity.this_two.account_id
  two_provider_region_name = data.aws_region.this_two.name

  three_provider_account_id  = data.aws_caller_identity.this_three.account_id
  three_provider_region_name = data.aws_region.this_three.name

  upper_env_prefix = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)
}

