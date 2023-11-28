variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "vpc_peering_deluxe" {
  description = "VPC Peering Deluxe configuration. Will create appropriate routes for all subnets in each VPC by default unless specific subnet cidrs are selected to route across the VPC peering connection via only_route_subnet_cidrs list is populated."
  type = object({
    allow_remote_vpc_dns_resolution = optional(bool, false)
    local = object({
      vpc = object({
        account_id              = string
        full_name               = string
        id                      = string
        name                    = string
        network_cidr            = string
        private_subnet_cidrs    = list(string)
        public_subnet_cidrs     = list(string)
        private_route_table_ids = list(string)
        public_route_table_ids  = list(string)
        region                  = string
      })
      only_route_subnet_cidrs = optional(list(string), [])
    })
    peer = object({
      vpc = object({
        account_id              = string
        full_name               = string
        id                      = string
        name                    = string
        network_cidr            = string
        private_subnet_cidrs    = list(string)
        public_subnet_cidrs     = list(string)
        private_route_table_ids = list(string)
        public_route_table_ids  = list(string)
        region                  = string
      })
      only_route_subnet_cidrs = optional(list(string), [])
    })
  })

  validation {
    condition     = length(var.vpc_peering_deluxe.local.only_route_subnet_cidrs) > 0 ? length(var.vpc_peering_deluxe.peer.only_route_subnet_cidrs) > 0 : true
    error_message = "If the var.vpc_peering_deluxe.local.only_route_subnet_cidrs is popluated then var.vpc_peering_deluxe.peer.only_route_subnet_cidrs must also be populated."
  }

  validation {
    condition     = length(var.vpc_peering_deluxe.peer.only_route_subnet_cidrs) > 0 ? length(var.vpc_peering_deluxe.local.only_route_subnet_cidrs) > 0 : true
    error_message = "If the var.vpc_peering_deluxe.peer.only_route_subnet_cidrs is popluated then var.vpc_peering_deluxe.local.only_route_subnet_cidrs must also be populated."
  }

  validation {
    condition = alltrue([
      for this in var.vpc_peering_deluxe.local.only_route_subnet_cidrs :
      contains(concat(var.vpc_peering_deluxe.local.vpc.private_subnet_cidrs, var.vpc_peering_deluxe.local.vpc.public_subnet_cidrs), this)
    ])
    error_message = "If the var.vpc_peering_deluxe.local.only_route_subnet_cidrs is popluated then all its subnets must already exist in the local VPC."
  }

  validation {
    condition = alltrue([
      for this in var.vpc_peering_deluxe.peer.only_route_subnet_cidrs :
      contains(concat(var.vpc_peering_deluxe.peer.vpc.private_subnet_cidrs, var.vpc_peering_deluxe.peer.vpc.public_subnet_cidrs), this)
    ])
    error_message = "If the var.vpc_peering_deluxe.peer.only_route_subnet_cidrs is popluated then all its subnets must already exist in the peer VPC."
  }

  validation {
    condition = length(distinct(
      [var.vpc_peering_deluxe.local.vpc.name, var.vpc_peering_deluxe.peer.vpc.name]
      )) == length(
      [var.vpc_peering_deluxe.local.vpc.name, var.vpc_peering_deluxe.peer.vpc.name]
    )
    error_message = "Each VPC name must be unique."
  }

  validation {
    condition = length(distinct(
      [var.vpc_peering_deluxe.local.vpc.network_cidr, var.vpc_peering_deluxe.peer.vpc.network_cidr]
      )) == length(
      [var.vpc_peering_deluxe.local.vpc.network_cidr, var.vpc_peering_deluxe.peer.vpc.network_cidr]
    )
    error_message = "Each VPC network cidr must be unique."
  }
}

variable "tags" {
  description = "Addtional Tags"
  type        = map(string)
  default     = {}
}
