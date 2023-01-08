variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "rule" {
  description = "security rule object to allow inbound across vpcs intra-vpc security group"
  type = object({
    label     = string
    protocol  = string
    from_port = number
    to_port   = number
  })
}

variable "vpcs" {
  description = "map of tiered_vpc_ng objects"
  type = map(object({
    id                          = string
    network                     = string
    intra_vpc_security_group_id = string
  }))

  validation {
    condition     = length(var.vpcs) > 1
    error_message = "There must be at least 2 VPCs."
  }
}
