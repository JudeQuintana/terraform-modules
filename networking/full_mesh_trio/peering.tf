locals {
  peering_name_format = "%s <-> %s"

  # renaming var to shorter name
  one_tgw   = var.full_mesh_trio.one.centralized_router
  two_tgw   = var.full_mesh_trio.two.centralized_router
  three_tgw = var.full_mesh_trio.three.centralized_router
}

########################################################################################
# Begin Full Mesh Trio One Side to Two Side
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_one_to_this_two" {
  provider = aws.one

  peer_account_id         = var.full_mesh_trio.two.centralized_router.account_id
  peer_region             = var.full_mesh_trio.two.centralized_router.region
  peer_transit_gateway_id = var.full_mesh_trio.two.centralized_router.id
  transit_gateway_id      = var.full_mesh_trio.one.centralized_router.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.one_full_mesh_trio_name, local.two_full_mesh_trio_name)
      Side = "One Creator"
    }
  )
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_one_to_this_two" {
  provider = aws.two

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_one_to_this_two.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.two_full_mesh_trio_name, local.one_full_mesh_trio_name)
      Side = "Two Accepter"
    }
  )
}

########################################################################################
# Begin Full Mesh Trio Two Side to Three Side
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_two_to_this_three" {
  provider = aws.two

  peer_account_id         = var.full_mesh_trio.three.centralized_router.account_id
  peer_region             = var.full_mesh_trio.three.centralized_router.region
  peer_transit_gateway_id = var.full_mesh_trio.three.centralized_router.id
  transit_gateway_id      = var.full_mesh_trio.two.centralized_router.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.two_full_mesh_trio_name, local.three_full_mesh_trio_name)
      Side = "Two Creator"
    }
  )
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_two_to_this_three" {
  provider = aws.three

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_two_to_this_three.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.three_full_mesh_trio_name, local.two_full_mesh_trio_name)
      Side = "Three Accepter"
    }
  )
}

########################################################################################
# Begin Full Mesh Trio Three Side to One Side
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_three_to_this_one" {
  provider = aws.three

  peer_account_id         = var.full_mesh_trio.one.centralized_router.account_id
  peer_region             = var.full_mesh_trio.one.centralized_router.region
  peer_transit_gateway_id = var.full_mesh_trio.one.centralized_router.id
  transit_gateway_id      = var.full_mesh_trio.three.centralized_router.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.three_full_mesh_trio_name, local.one_full_mesh_trio_name)
      Side = "Three Creator"
    }
  )
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_three_to_this_one" {
  provider = aws.one

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_three_to_this_one.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.one_full_mesh_trio_name, local.three_full_mesh_trio_name)
      Side = "One Accepter"
    }
  )
}

