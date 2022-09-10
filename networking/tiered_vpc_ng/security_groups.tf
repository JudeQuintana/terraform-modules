locals {
  intra_vpc_security_group_name = format("%s-%s-%s-%s", local.upper_env_prefix, local.region_label, local.tier.name, "intra-vpc")
}

# SG rules will be added to this by the Intra VPC Security Group Rule module
# for access across VPCs
resource "aws_security_group" "intra_vpc" {
  name        = local.intra_vpc_security_group_name
  description = "Intra VPC traffic over Transit Gateway"
  vpc_id      = aws_vpc.this.id
  tags = merge(local.default_tags,
    {
      Name = local.intra_vpc_security_group_name
    }
  )
}
