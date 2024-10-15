########################################################################################
# Begin Full Mesh Trio One TGW to Two TGW
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
