locals {
  vpc_attachment_format = "%s <-> %s"
  vpc_id_to_vpc         = { for this in var.centralized_router.vpcs : this.id => this }
}

# Use the special public subnet ids for each az per tiered vpc to be used for each vpc attachment because they will always exist for a tiered vpc.
# This means VPC attachments will use one public subnet from each AZ to route traffic.
# This enables traffic to reach resources in every subnet in that AZ.
# The public subnet that it will use will be only one with the special attibute set to true per AZ ie `special = true`.
# I'm not sure about security implications of this pattern but I dont think it matters.
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = local.vpc_id_to_vpc

  subnet_ids                                      = each.value.public_special_subnet_ids
  transit_gateway_id                              = aws_ec2_transit_gateway.this.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  vpc_id                                          = each.key
  tags = merge(
    local.default_tags,
    {
      Name = format(
        local.vpc_attachment_format,
        each.value.full_name,
        local.centralized_router_name
      )
    }
  )
}

# associate attachments to route table
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = local.vpc_id_to_vpc

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}

# route table propagation
resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = local.vpc_id_to_vpc

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}
