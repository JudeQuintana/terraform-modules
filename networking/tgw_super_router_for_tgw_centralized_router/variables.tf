variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}

variable "local_amazon_side_asn" {
  description = "required local amazon side asn"
  type        = number
}

variable "local_centralized_routers" {
  description = "list of centralized router objects for local provider"
  type = list(object({
    account_id      = string
    amazon_side_asn = string
    full_name       = string
    id              = string
    networks        = list(string)
    region          = string
    route_table_id  = string
    vpc_routes = list(object({
      route_table_id         = string
      destination_cidr_block = string
      transit_gateway_id     = string
    }))
    vpcs = map(object({
      network                      = string
      az_to_public_route_table_id  = map(string)
      az_to_private_route_table_id = map(string)
    }))
  }))

  validation {
    condition = length(
      distinct(var.local_centralized_routers[*].amazon_side_asn)
    ) == length(var.local_centralized_routers[*].amazon_side_asn)
    error_message = "All local centralized routers must have a unique amazon_side_asn number."
  }

  validation {
    condition     = length(distinct(var.local_centralized_routers[*].region)) < 2
    error_message = "All local centralized routers must have the same region as each other and the aws.local provider alias."
  }

  validation {
    condition     = length(distinct(var.local_centralized_routers[*].account_id)) < 2
    error_message = "All local centralized routers must have the same account id as each other and the aws.local provider alias."
  }

  default = []
}

variable "peer_centralized_routers" {
  description = "list of centralized router objects for remote provider"
  type = list(object({
    account_id      = string
    amazon_side_asn = string
    full_name       = string
    id              = string
    networks        = list(string)
    region          = string
    route_table_id  = string
    vpc_routes = list(object({
      route_table_id         = string
      destination_cidr_block = string
      transit_gateway_id     = string
    }))
    vpcs = map(object({
      network                      = string
      az_to_public_route_table_id  = map(string)
      az_to_private_route_table_id = map(string)
    }))
  }))


  validation {
    condition = length(
      distinct(var.peer_centralized_routers[*].amazon_side_asn)
    ) == length(var.peer_centralized_routers[*].amazon_side_asn)
    error_message = "All peer centralized routers must have a unique amazon_side_asn number."
  }

  validation {
    condition     = length(distinct(var.peer_centralized_routers[*].region)) < 2
    error_message = "All peer centralized routers must have the same region as each other and the aws.peer provider alias."
  }

  validation {
    condition     = length(distinct(var.peer_centralized_routers[*].account_id)) < 2
    error_message = "All peer centralized couters must have the same account id as each other and the aws.peer provider alias."
  }

  default = []
}
