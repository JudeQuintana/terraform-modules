output "vpc" {
  value = {
    id            = aws_vpc.this.id
    cidr          = aws_vpc.this.cidr_block
    default_sg_id = aws_vpc.this.default_security_group_id
    igw_id        = aws_internet_gateway.this.id
  }
}

locals {
  private_subnet_to_subnet_ids   = { for subnet, this in aws_subnet.private : subnet => this.id }
  private_subnet_ids_per_az      = { for subnet, subnet_id in local.private_subnet_to_subnet_ids : lookup(local.private_subnet_to_azs, subnet) => subnet_id... } # group subnet_id by AZ of subnet
  private_route_table_ids_per_az = { for az, route_table in aws_route_table.private : az => route_table.id }

  public_subnet_to_subnet_ids   = { for subnet, this in aws_subnet.public : subnet => this.id }
  public_subnet_ids_per_az      = { for subnet, subnet_id in local.public_subnet_to_subnet_ids : lookup(local.public_subnet_to_azs, subnet) => subnet_id... } # group subnet_id by AZ of subnet
  public_route_table_ids_per_az = { for az, subnet_id in local.public_subnet_ids_per_az : az => aws_route_table.public.id }                                   # Each public subnet shares the same route table
}

output "public_subnet_ids" {
  value = local.public_subnet_ids_per_az
}

output "public_route_table_ids" {
  value = local.public_route_table_ids_per_az
}

output "private_subnet_ids" {
  value = local.private_subnet_ids_per_az
}

output "private_route_table_ids" {
  value = local.private_route_table_ids_per_az
}

locals {
  tier_bundle = {
    for az, acl in var.tier.azs : az => {
      private                = acl.private != null ? acl.private : []
      private_ids            = lookup(local.private_subnet_ids_per_az, az, [])
      private_route_table_id = lookup(local.private_route_table_ids_per_az, az, null)
      public                 = acl.public
      public_ids             = lookup(local.public_subnet_ids_per_az, az)
      public_route_table_id  = lookup(local.public_route_table_ids_per_az, az) # no default because there will always be a public route table
    }
  }
}

output "tier_bundle" {
  value = local.tier_bundle
}

locals {
  tier_structured = {
    for az, acl in var.tier.azs : az => {
      private = [for subnet, subnet_id in local.private_subnet_to_subnet_ids :
        {
          subnet = subnet
          id     = subnet_id
        }
      if lookup(local.private_subnet_to_azs, subnet) == az]
      private_route_table_id = lookup(local.private_route_table_ids_per_az, az, null)

      public = [for subnet, subnet_id in local.public_subnet_to_subnet_ids :
        {
          subnet = subnet
          id     = subnet_id
        }
      if lookup(local.public_subnet_to_azs, subnet) == az]
      public_route_table_id = lookup(local.public_route_table_ids_per_az, az)
    }
  }
}

output "tier" {
  value = local.tier_structured
}
