variable "env_prefix" {
  description = "prod, stage, etc"
  type        = string
}

variable "vpc_attributes" {
  description = "Need base CIDR and AZ to Subnet map"
  type = object({
    vpc_cidr = string
    azs      = map(number)
  })
}

variable "region_az_short_names" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "vpc_tenancy" {
  description = "Set VPC Tenancy"
  type        = string
  default     = "default"
}

