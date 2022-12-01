# Overview

Used to generate tiered subnets for a VPC. Please see my [Tiered Subnet
Calculator](https://jq1.io/posts/tiered_subnet_calculator/) blog post for a more detailed explanation.

# Usage
`tiers.auto.tfvars`
```
base_cidr_block = "10.0.0.0/16"

tiers = [
  {
    name   = "app"
    acl    = "public"
    newbit = 4
  },
  {
    name   = "db"
    acl    = "private"
    newbit = 4
  },
  {
    name   = "worker"
    acl    = "private"
    newbit = 4
  },
  {
    name   = "lbs"
    acl    = "public"
    newbit = 4
  }
]

az_newbits = {
  a = 4
  b = 4
  c = 4
  d = 4
}

```

`terraform apply -refresh-only`
```
$ terraform apply -refresh-only

Changes to Outputs:
  + calculated_tiers = [
      + {
          + acl     = "private"
          + azs     = {
              + "a" = "10.0.0.0/24"
              + "b" = "10.0.1.0/24"
              + "c" = "10.0.2.0/24"
              + "d" = "10.0.3.0/24"
            }
          + name    = "db"
          + network = "10.0.0.0/20"
        },
      + {
          + acl     = "private"
          + azs     = {
              + "a" = "10.0.16.0/25"
              + "b" = "10.0.16.128/25"
              + "c" = "10.0.17.0/25"
              + "d" = "10.0.17.128/25"
            }
          + name    = "worker"
          + network = "10.0.16.0/21"
        },
      + {
          + acl     = "public"
          + azs     = {
              + "a" = "10.0.32.0/23"
              + "b" = "10.0.34.0/23"
              + "c" = "10.0.36.0/23"
              + "d" = "10.0.38.0/23"
            }
          + name    = "app"
          + network = "10.0.32.0/19"
        },
      + {
          + acl     = "public"
          + azs     = {
              + "a" = "10.0.64.0/26"
              + "b" = "10.0.64.64/26"
              + "c" = "10.0.64.128/26"
              + "d" = "10.0.64.192/26"
            }
          + name    = "lbs"
          + network = "10.0.64.0/22"
        },
    ]

You can apply this plan to save these new output values to the Terraform state,
without changing any real infrastructure.

Would you like to update the Terraform state to reflect these detected changes?
  Terraform will write these changes to the state without modifying any real infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

calculated_tiers = [
  {
    "acl" = "private"
    "azs" = tomap({
      "a" = "10.0.0.0/24"
      "b" = "10.0.1.0/24"
      "c" = "10.0.2.0/24"
      "d" = "10.0.3.0/24"
    })
    "name" = "db"
    "network" = "10.0.0.0/20"
  },
  {
    "acl" = "private"
    "azs" = tomap({
      "a" = "10.0.16.0/25"
      "b" = "10.0.16.128/25"
      "c" = "10.0.17.0/25"
      "d" = "10.0.17.128/25"
    })
    "name" = "worker"
    "network" = "10.0.16.0/21"
  },
  {
    "acl" = "public"
    "azs" = tomap({
      "a" = "10.0.32.0/23"
      "b" = "10.0.34.0/23"
      "c" = "10.0.36.0/23"
      "d" = "10.0.38.0/23"
    })
    "name" = "app"
    "network" = "10.0.32.0/19"
  },
  {
    "acl" = "public"
    "azs" = tomap({
      "a" = "10.0.64.0/26"
      "b" = "10.0.64.64/26"
      "c" = "10.0.64.128/26"
      "d" = "10.0.64.192/26"
    })
    "name" = "lbs"
    "network" = "10.0.64.0/22"
  },
]
```

