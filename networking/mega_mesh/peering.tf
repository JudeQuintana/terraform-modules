locals {
  peering_name_format = "%s <-> %s"

  # renaming var to shorter internal name
  one_tgw   = var.mega_mesh.one.centralized_router
  two_tgw   = var.mega_mesh.two.centralized_router
  three_tgw = var.mega_mesh.three.centralized_router
  four_tgw  = var.mega_mesh.four.centralized_router
  five_tgw  = var.mega_mesh.five.centralized_router
}

########################################################################################
# Begin Mega Mesh One TGW to Two TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_one_to_this_two" {
  provider = aws.one

  transit_gateway_id      = local.one_tgw.id
  peer_account_id         = local.two_tgw.account_id
  peer_region             = local.two_tgw.region
  peer_transit_gateway_id = local.two_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.one_tgw.full_name, local.two_tgw.full_name)
      Side = "One Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_one_to_this_two" {
  provider = aws.two

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_one_to_this_two.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.two_tgw.full_name, local.one_tgw.full_name)
      Side = "Two Accepter"
    }
  )
}

########################################################################################
# Begin Mega Mesh Two TGW to Three TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_two_to_this_three" {
  provider = aws.two

  transit_gateway_id      = local.two_tgw.id
  peer_account_id         = local.three_tgw.account_id
  peer_region             = local.three_tgw.region
  peer_transit_gateway_id = local.three_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.two_tgw.full_name, local.three_tgw.full_name)
      Side = "Two Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_two_to_this_three" {
  provider = aws.three

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_two_to_this_three.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.three_tgw.full_name, local.two_tgw.full_name)
      Side = "Three Accepter"
    }
  )
}

########################################################################################
# Begin Mega Mesh Three TGW to One TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_three_to_this_one" {
  provider = aws.three

  transit_gateway_id      = local.three_tgw.id
  peer_account_id         = local.one_tgw.account_id
  peer_region             = local.one_tgw.region
  peer_transit_gateway_id = local.one_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.three_tgw.full_name, local.one_tgw.full_name)
      Side = "Three Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_three_to_this_one" {
  provider = aws.one

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_three_to_this_one.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.one_tgw.full_name, local.three_tgw.full_name)
      Side = "One Accepter"
    }
  )
}

########################################################################################
# Begin Mega Mesh Four TGW to One TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_four_to_this_one" {
  provider = aws.four

  transit_gateway_id      = local.four.id
  peer_account_id         = local.one_tgw.account_id
  peer_region             = local.one_tgw.region
  peer_transit_gateway_id = local.one_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.four_tgw.full_name, local.one_tgw.full_name)
      Side = "Four Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_four_to_this_one" {
  provider = aws.four

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_four_to_this_one.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.one_tgw.full_name, local.four_tgw.full_name)
      Side = "One Accepter"
    }
  )
}

########################################################################################
# Begin Mega Mesh Four TGW to Two TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_four_to_this_two" {
  provider = aws.four

  transit_gateway_id      = local.four_tgw.id
  peer_account_id         = local.two_tgw.account_id
  peer_region             = local.two_tgw.region
  peer_transit_gateway_id = local.two_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.four_tgw.full_name, local.two_tgw.full_name)
      Side = "Four Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_four_to_this_two" {
  provider = aws.two

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_four_to_this_two.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.two_tgw.full_name, local.four_tgw.full_name)
      Side = "Two Accepter"
    }
  )
}

########################################################################################
# Begin Mega Mesh Four TGW to Three TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_four_to_this_three" {
  provider = aws.four

  transit_gateway_id      = local.four_tgw.id
  peer_account_id         = local.three_tgw.account_id
  peer_region             = local.three_tgw.region
  peer_transit_gateway_id = local.three_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.four_tgw.full_name, local.three_tgw.full_name)
      Side = "Four Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_four_to_this_three" {
  provider = aws.three

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_four_to_this_three.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.three_tgw.full_name, local.four_tgw.full_name)
      Side = "Three Accepter"
    }
  )
}


########################################################################################
# Begin Mega Mesh Five TGW to One TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_five_to_this_one" {
  provider = aws.five

  transit_gateway_id      = local.five.id
  peer_account_id         = local.one_tgw.account_id
  peer_region             = local.one_tgw.region
  peer_transit_gateway_id = local.one_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.five_tgw.full_name, local.one_tgw.full_name)
      Side = "Five Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_five_to_this_one" {
  provider = aws.five

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_five_to_this_one.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.one_tgw.full_name, local.five_tgw.full_name)
      Side = "One Accepter"
    }
  )
}

########################################################################################
# Begin Mega Mesh Five TGW to Two TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_five_to_this_two" {
  provider = aws.five

  transit_gateway_id      = local.five_tgw.id
  peer_account_id         = local.two_tgw.account_id
  peer_region             = local.two_tgw.region
  peer_transit_gateway_id = local.two_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.five_tgw.full_name, local.two_tgw.full_name)
      Side = "Five Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_five_to_this_two" {
  provider = aws.two

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_five_to_this_two.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.two_tgw.full_name, local.five_tgw.full_name)
      Side = "Two Accepter"
    }
  )
}

########################################################################################
# Begin Mega Mesh Five TGW to Three TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_five_to_this_three" {
  provider = aws.five

  transit_gateway_id      = local.five_tgw.id
  peer_account_id         = local.three_tgw.account_id
  peer_region             = local.three_tgw.region
  peer_transit_gateway_id = local.three_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.five_tgw.full_name, local.three_tgw.full_name)
      Side = "Five Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_five_to_this_three" {
  provider = aws.three

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_five_to_this_three.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.three_tgw.full_name, local.five_tgw.full_name)
      Side = "Three Accepter"
    }
  )
}

########################################################################################
# Begin Mega Mesh Five TGW to Four TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_five_to_this_four" {
  provider = aws.five

  transit_gateway_id      = local.five_tgw.id
  peer_account_id         = local.four_tgw.account_id
  peer_region             = local.four_tgw.region
  peer_transit_gateway_id = local.four_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.five_tgw.full_name, local.four_tgw.full_name)
      Side = "Five Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_five_to_this_four" {
  provider = aws.four

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_five_to_this_four.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.four_tgw.full_name, local.five_tgw.full_name)
      Side = "Four Accepter"
    }
  )
}

########################################################################################
# Begin Mega Mesh Six TGW to One TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_six_to_this_one" {
  provider = aws.six

  transit_gateway_id      = local.six.id
  peer_account_id         = local.one_tgw.account_id
  peer_region             = local.one_tgw.region
  peer_transit_gateway_id = local.one_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.six_tgw.full_name, local.one_tgw.full_name)
      Side = "Six Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_six_to_this_one" {
  provider = aws.six

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_six_to_this_one.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.one_tgw.full_name, local.six_tgw.full_name)
      Side = "One Accepter"
    }
  )
}

########################################################################################
# Begin Mega Mesh Six TGW to Two TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_six_to_this_two" {
  provider = aws.six

  transit_gateway_id      = local.six_tgw.id
  peer_account_id         = local.two_tgw.account_id
  peer_region             = local.two_tgw.region
  peer_transit_gateway_id = local.two_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.six_tgw.full_name, local.two_tgw.full_name)
      Side = "Six Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_six_to_this_two" {
  provider = aws.two

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_six_to_this_two.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.two_tgw.full_name, local.six_tgw.full_name)
      Side = "Two Accepter"
    }
  )
}

########################################################################################
# Begin Mega Mesh six TGW to Three TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_six_to_this_three" {
  provider = aws.six

  transit_gateway_id      = local.six_tgw.id
  peer_account_id         = local.three_tgw.account_id
  peer_region             = local.three_tgw.region
  peer_transit_gateway_id = local.three_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.six_tgw.full_name, local.three_tgw.full_name)
      Side = "Six Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_six_to_this_three" {
  provider = aws.three

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_six_to_this_three.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.three_tgw.full_name, local.six_tgw.full_name)
      Side = "Three Accepter"
    }
  )
}

########################################################################################
# Begin Mega Mesh six TGW to Four TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_six_to_this_four" {
  provider = aws.six

  transit_gateway_id      = local.six_tgw.id
  peer_account_id         = local.four_tgw.account_id
  peer_region             = local.four_tgw.region
  peer_transit_gateway_id = local.four_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.six_tgw.full_name, local.four_tgw.full_name)
      Side = "Six Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_six_to_this_four" {
  provider = aws.four

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_six_to_this_four.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.four_tgw.full_name, local.six_tgw.full_name)
      Side = "Four Accepter"
    }
  )
}

########################################################################################
# Begin Mega Mesh six TGW to Five TGW
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_six_to_this_five" {
  provider = aws.six

  transit_gateway_id      = local.six_tgw.id
  peer_account_id         = local.five_tgw.account_id
  peer_region             = local.five_tgw.region
  peer_transit_gateway_id = local.five_tgw.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.six_tgw.full_name, local.five_tgw.full_name)
      Side = "Six Creator"
    }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # tgw region and account id preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.one_tgw_provider_region_check.condition
      error_message = local.one_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.one_tgw_provider_account_id_check.condition
      error_message = local.one_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_region_check.condition
      error_message = local.two_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.two_tgw_provider_account_id_check.condition
      error_message = local.two_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_region_check.condition
      error_message = local.three_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.three_tgw_provider_account_id_check.condition
      error_message = local.three_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_region_check.condition
      error_message = local.four_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.four_tgw_provider_account_id_check.condition
      error_message = local.four_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_region_check.condition
      error_message = local.five_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.five_tgw_provider_account_id_check.condition
      error_message = local.five_tgw_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_region_check.condition
      error_message = local.six_tgw_provider_region_check.error_message
    }

    precondition {
      condition     = local.six_tgw_provider_account_id_check.condition
      error_message = local.six_tgw_provider_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_six_to_this_five" {
  provider = aws.five

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_six_to_this_five.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.five_tgw.full_name, local.six_tgw.full_name)
      Side = "Five Accepter"
    }
  )
}

