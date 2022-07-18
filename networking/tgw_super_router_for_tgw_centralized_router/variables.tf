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
    id             = string
    name           = string
    route_table_id = string
    region         = string
    account_id     = string
    networks       = list(string)
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

  default = []

}

variable "peer_centralized_routers" {
  description = "list of centralized router objects for remote provider"
  type = list(object({
    id             = string
    name           = string
    route_table_id = string
    region         = string
    account_id     = string
    networks       = list(string)
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

  default = []
  # validation
}
