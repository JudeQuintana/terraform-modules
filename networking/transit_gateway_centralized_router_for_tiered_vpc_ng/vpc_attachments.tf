locals {
  # Collect the first public subnet for each az per tiered vpc to be used for each vpc attachment.
  # I'm using public subnets because they will always exist for a tiered vpc.
  # This means VPC attachments will use one public subnet from each AZ to route traffic.
  # This enables traffic to reach resources in every subnet in that AZ.
  # The public subnet that it will use will be only one with the special attibute set to true per AZ ie `special = true`.
  # I'm not sure about security implications of this pattern but I dont think it matters.
  #
  # { vpc-1-id  = [ "special-public-subnet-id-of-az-1-for-vpc-1", "special-public-subnet-id-of-az-2-for-vpc-1", ... ], ...}
  vpc_id_to_public_special_subnet_ids = { for this in local.vpcs : this.id => this.public_special_subnet_ids }

  # lookup table for each aws_ec2_transit_gateway_vpc_attachment to get the name based on id
  vpc_id_to_full_name = { for this in local.vpcs : this.id => this.full_name }
}

# attach vpcs to tgw
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = local.vpc_id_to_public_special_subnet_ids

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
        lookup(local.vpc_id_to_full_name, each.key),
        local.centralized_router_name
      )
    }
  )
}

# associate attachments to route table
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = local.vpc_id_to_public_special_subnet_ids

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}

# route table propagation
resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = local.vpc_id_to_public_special_subnet_ids

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}
