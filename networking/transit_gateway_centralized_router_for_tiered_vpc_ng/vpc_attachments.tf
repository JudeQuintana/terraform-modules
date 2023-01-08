locals {
  # collect the first public subnet for each az per tiered vpc to be used for each vpc attachment.
  # i'm using public subnets because they will always exist for a tiered vpc.
  # this means routing will go through a public subnet to get to a private subnet in the same AZ
  # private subnets could be used too
  # i'm not sure about security implications of this pattern but i dont think it matters.
  #
  # { vpc-1-id  = [ "first-public-subnet-id-of-az-1-for-vpc-1", "first-public-subnet-id-of-az-2-for-vpc-1", ... ], ...}
  vpc_id_to_single_public_subnet_ids_per_az = {
    for this in var.centralized_router.vpcs :
    this.id => [for az, public_subnet_ids in this.az_to_public_subnet_ids : element(public_subnet_ids, 0)]
  }

  # lookup table for each aws_ec2_transit_gateway_vpc_attachment to get the name based on id
  vpc_id_to_full_names = { for this in var.centralized_router.vpcs : this.id => this.full_name }
}

# attach vpcs to tgw
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = local.vpc_id_to_single_public_subnet_ids_per_az

  subnet_ids                                      = each.value
  transit_gateway_id                              = aws_ec2_transit_gateway.this.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  vpc_id                                          = each.key
  tags = merge(
    local.default_tags,
    {
      Name = format(
        local.vpc_attachment_format,
        lookup(local.vpc_id_to_full_names, each.key),
        local.centralized_router_name
      )
    }
  )
}

# associate attachments to route table
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = local.vpc_id_to_single_public_subnet_ids_per_az

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}

# route table propagation
resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = local.vpc_id_to_single_public_subnet_ids_per_az

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}
