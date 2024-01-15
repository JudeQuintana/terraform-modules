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

data "aws_caller_identity" "this_four" {
  provider = aws.four
}

data "aws_region" "this_four" {
  provider = aws.four
}

data "aws_caller_identity" "this_five" {
  provider = aws.five
}

data "aws_region" "this_five" {
  provider = aws.five
}

data "aws_caller_identity" "this_six" {
  provider = aws.six
}

data "aws_region" "this_six" {
  provider = aws.six
}

locals {
  one_provider_account_id  = data.aws_caller_identity.this_one.account_id
  one_provider_region_name = data.aws_region.this_one.name

  two_provider_account_id  = data.aws_caller_identity.this_two.account_id
  two_provider_region_name = data.aws_region.this_two.name

  three_provider_account_id  = data.aws_caller_identity.this_three.account_id
  three_provider_region_name = data.aws_region.this_three.name

  four_provider_account_id  = data.aws_caller_identity.this_four.account_id
  four_provider_region_name = data.aws_region.this_four.name

  five_provider_account_id  = data.aws_caller_identity.this_five.account_id
  five_provider_region_name = data.aws_region.this_five.name

  six_provider_account_id  = data.aws_caller_identity.this_six.account_id
  six_provider_region_name = data.aws_region.this_six.name

  upper_env_prefix = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)
}

