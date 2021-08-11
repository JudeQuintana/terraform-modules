locals {
  intra_vpc_security_group_name = format("%s-%s-%s-%s", upper(var.env_prefix), local.region_label, local.tier.name, "intra-vpc")
}

resource "aws_security_group" "intra_vpc" {
  name        = local.intra_vpc_security_group_name
  description = "Intra VPC traffic over Transit Gateway"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = local.intra_vpc_security_group_name
  }
}
