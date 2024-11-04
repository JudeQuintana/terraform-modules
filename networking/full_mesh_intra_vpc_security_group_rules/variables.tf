variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "full_mesh_intra_vpc_security_group_rules" {
  description = "full mesh intra vpc security group rules configuration"
  type = object({
    # security rule object to allow inbound across vpcs intra-vpc security group
    one = object({
      intra_vpc_security_group_rules = map(object({
        account_id = string
        region     = string
        rule = object({
          label     = string
          protocol  = string
          from_port = number
          to_port   = number
        })
        vpcs = map(object({
          id                          = string
          intra_vpc_security_group_id = string
          network_cidr                = string
          secondary_cidrs             = optional(list(string), [])
        }))
    })) })
    two = object({
      intra_vpc_security_group_rules = map(object({
        account_id = string
        region     = string
        rule = object({
          label     = string
          protocol  = string
          from_port = number
          to_port   = number
        })
        vpcs = map(object({
          id                          = string
          intra_vpc_security_group_id = string
          network_cidr                = string
          secondary_cidrs             = optional(list(string), [])
        }))
    })) })
    three = object({
      intra_vpc_security_group_rules = map(object({
        account_id = string
        region     = string
        rule = object({
          label     = string
          protocol  = string
          from_port = number
          to_port   = number
        })
        vpcs = map(object({
          id                          = string
          intra_vpc_security_group_id = string
          network_cidr                = string
          secondary_cidrs             = optional(list(string), [])
        }))
    })) })
  })

  # One
  validation {
    condition = length(distinct([
      for this in var.full_mesh_intra_vpc_security_group_rules.one.intra_vpc_security_group_rules : this.region
    ])) <= 1
    error_message = "The Intra VPC Security Group Rules for One must have the same region as each other and the aws.one provider alias for Full Mesh Intra VPC Security Group Rules."
  }

  validation {
    condition = length(distinct([
      for this in var.full_mesh_intra_vpc_security_group_rules.one.intra_vpc_security_group_rules : this.account_id
    ])) <= 1
    error_message = "The Intra VPC Security Group Rules for One must have the same account id as each other and the aws.one provider alias for Full Mesh Intra VPC Security Group Rules."
  }

  validation {
    condition     = alltrue([for this in var.full_mesh_intra_vpc_security_group_rules.one.intra_vpc_security_group_rules : length(this.vpcs) > 1])
    error_message = "There must be at least 2 VPCs per Intra VPC Security Group Rule for One."
  }

  # Two
  validation {
    condition = length(distinct([
      for this in var.full_mesh_intra_vpc_security_group_rules.two.intra_vpc_security_group_rules : this.region
    ])) <= 1
    error_message = "The Intra VPC Security Group Rules for Two must have the same region as each other and the aws.two provider alias for Full Mesh Intra VPC Security Group Rules."
  }

  validation {
    condition = length(distinct([
      for this in var.full_mesh_intra_vpc_security_group_rules.two.intra_vpc_security_group_rules : this.account_id
    ])) <= 1
    error_message = "The Intra VPC Security Group Rules for Two must have the same account id as each other and the aws.two provider alias for Full Mesh Intra VPC Security Group Rules."
  }

  validation {
    condition     = alltrue([for this in var.full_mesh_intra_vpc_security_group_rules.two.intra_vpc_security_group_rules : length(this.vpcs) > 1])
    error_message = "There must be at least 2 VPCs per Intra VPC Security Group Rule for Two."
  }

  # Three
  validation {
    condition = length(distinct([
      for this in var.full_mesh_intra_vpc_security_group_rules.three.intra_vpc_security_group_rules : this.region
    ])) <= 1
    error_message = "The Intra VPC Security Group Rules for Three must have the same region as each other and the aws.three provider alias for Full Mesh Intra VPC Security Group Rules."
  }

  validation {
    condition = length(distinct([
      for this in var.full_mesh_intra_vpc_security_group_rules.three.intra_vpc_security_group_rules : this.account_id
    ])) <= 1
    error_message = "The Intra VPC Security Group Rules for Three must have the same account id as each other and the aws.three provider alias for Full Mesh Intra VPC Security Group Rules."
  }

  validation {
    condition     = alltrue([for this in var.full_mesh_intra_vpc_security_group_rules.three.intra_vpc_security_group_rules : length(this.vpcs) > 1])
    error_message = "There must be at least 2 VPCs per Intra VPC Security Group Rule for Three."
  }

  # cross region rules check
  validation {
    condition = [
      for this in var.full_mesh_intra_vpc_security_group_rules.one.intra_vpc_security_group_rules : this.rule
      ] == [
      for this in var.full_mesh_intra_vpc_security_group_rules.two.intra_vpc_security_group_rules : this.rule
      ] && [
      for this in var.full_mesh_intra_vpc_security_group_rules.two.intra_vpc_security_group_rules : this.rule
      ] == [
      for this in var.full_mesh_intra_vpc_security_group_rules.three.intra_vpc_security_group_rules : this.rule
      ] && [
      for this in var.full_mesh_intra_vpc_security_group_rules.three.intra_vpc_security_group_rules : this.rule
      ] == [
      for this in var.full_mesh_intra_vpc_security_group_rules.one.intra_vpc_security_group_rules : this.rule
    ]
    error_message = "The Intra VPC Security Group Rules for One, Two and Three must all have the same set of rules as each other for Full Mesh Intra VPC Security Group Rules."
  }
}

