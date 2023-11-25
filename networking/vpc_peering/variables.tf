variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "vpc_peering" {
  type = object({
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
    })
  })
}

variable "tags" {
  description = "Addtional Tags"
  type        = map(string)
  default     = {}
}
