variable "env_prefix" {
  description = "prod, stage, etc"
  type        = string
}

variable "region_az_short_names" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "cidr_block" {
  description = "Base VPC CIDR Block ie 10.0.0.0/16"
  type        = string
}

variable "azs" {
  description = "AZ (letter) to Subnet (number for 3rd octet)"
  type        = map(number)
}

variable "vpc_tenancy" {
  description = "Set VPC Tenancy"
  type        = string
  default     = "default"
}

