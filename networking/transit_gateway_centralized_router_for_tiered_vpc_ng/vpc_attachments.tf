locals {
  vpc_attachment_format = "%s <-> %s"
  vpc_id_to_vpc         = { for this in var.centralized_router.vpcs : this.id => this }
}

# VPC attachments will use either a private subnet or public subnet tagged as speciale from each AZ to route traffic.
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = local.vpc_id_to_vpc

  subnet_ids                                      = concat(each.value.private_special_subnet_ids, each.value.public_special_subnet_ids)
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
