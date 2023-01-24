variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "super_intra_vpc_security_group_rules" {
  description = "super intra vpc security group rules configuration"
  type = object({
    # security rule object to allow inbound across vpcs intra-vpc security group
    local = object({
      intra_vpc_security_group_rules = map(object({
        rule = object({
          label      = string
          protocol   = string
          from_port  = number
          to_port    = number
          account_id = string
          region     = string
        })
        vpcs = map(object({
          id = string
          #name                        = string
          intra_vpc_security_group_id = string
          network_cidr                = string
          account_id                  = string
          region                      = string
        }))
    })) })
    peer = object({
      intra_vpc_security_group_rules = map(object({
        rule = object({
          label      = string
          protocol   = string
          from_port  = number
          to_port    = number
          account_id = string
          region     = string
        })
        vpcs = map(object({
          id = string
          #name                        = string
          intra_vpc_security_group_id = string
          network_cidr                = string
          account_id                  = string
          region                      = string
        }))
    })) })
  })

  #validations for labels, protocol, regions, account_id
  # Local Rules

  # Local VPCs
  validation {
    condition = length(distinct(flatten([
      for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules : [
        for vpc in this.vpcs : vpc.account_id
    ]]))) <= 1
    error_message = "All local VPCs must have the same account id as each other."
  }

  validation {
    condition     = alltrue([for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules : length(this.vpcs) > 1])
    error_message = "There must be at least 2 local VPCs."
  }

  # last 2 validations not working
  #
  #validation {
  #condition = length(distinct(flatten([
  #for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules : [
  #for vpc in this.vpcs : vpc.name
  #]]))) == length(flatten([
  #for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules : [
  #for vpc in this.vpcs : vpc.name
  #]]))
  #error_message = "All local VPCs must have unique names."
  #}

  #validation {
  #condition = length(distinct(flatten([
  #for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules : [
  #for vpc in this.vpcs : vpc.network_cidr
  #]]))) == length(flatten([
  #for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules : [
  #for vpc in this.vpcs : vpc.network_cidr
  #]]))
  #error_message = "All VPCs must have unique network CIDRs."
  #}

}
