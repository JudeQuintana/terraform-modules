# several parts of toolchain use this lookup
locals {
  # cidr (primary or secondary) -> vpc name
  cidr_to_vpc_name = merge([
    for name, vpc in var.vpcs : {
      for cidr in concat([vpc.network_cidr], vpc.secondary_cidrs) :
      cidr => name
  }]...)
}

