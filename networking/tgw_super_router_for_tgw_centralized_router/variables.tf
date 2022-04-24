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
  type    = number
  default = null
}

variable "local_centralized_routers" {
  description = "list of centralized router objects for local provider"
  type = list(object({
    id             = string
    route_table_id = string
    region         = string
    account_id     = string
    #vpcs                         = map(object({
    #network                      = string
    #az_to_public_route_table_id  = map(string)
    #az_to_private_route_table_id = map(string)
    #}))
  }))
  # include region and caller_identity.account_id?
  # validation
}

variable "local_tgw_routes" {
  description = "additional blackhole and override routes?"
  type = list(object({
    destination_network           = string
    blackhole                     = bool   #optional
    transit_gateway_attachment_id = string #optional?
  }))
  default = []
  #validation
}

variable "remote_centralized_routers" {
  description = "list of centralized router objects for remote provider"
  type = list(object({
    id             = string
    route_table_id = string
    vpcs = map(object({
      network                      = string
      az_to_public_route_table_id  = map(string)
      az_to_private_route_table_id = map(string)
    }))
  }))
  default = []
  # validation
}
