# Update Dec 17th 2022

Things have changed since TF v0.13 like the resulting order for a list of objects with `for`.

So the [Tiered Subnet
Calculator](https://jq1.io/posts/tiered_subnet_calculator/) article is outdated if you're using a more recent version of Terraform.

I'll try to update article when I can.

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

`terraform apply`
```
$ terraform apply

Changes to Outputs:
  + calculated_tiers = [
      + {
          + acl     = "public"
          + azs     = {
              + "a" = "10.0.0.0/24"
              + "b" = "10.0.1.0/24"
              + "c" = "10.0.2.0/24"
              + "d" = "10.0.3.0/24"
            }
          + name    = "app"
          + network = "10.0.0.0/20"
        },
      + {
          + acl     = "private"
          + azs     = {
              + "a" = "10.0.16.0/24"
              + "b" = "10.0.17.0/24"
              + "c" = "10.0.18.0/24"
              + "d" = "10.0.19.0/24"
            }
          + name    = "db"
          + network = "10.0.16.0/20"
        },
      + {
          + acl     = "private"
          + azs     = {
              + "a" = "10.0.32.0/24"
              + "b" = "10.0.33.0/24"
              + "c" = "10.0.34.0/24"
              + "d" = "10.0.35.0/24"
            }
          + name    = "worker"
          + network = "10.0.32.0/20"
        },
      + {
          + acl     = "public"
          + azs     = {
              + "a" = "10.0.48.0/24"
              + "b" = "10.0.49.0/24"
              + "c" = "10.0.50.0/24"
              + "d" = "10.0.51.0/24"
            }
          + name    = "lbs"
          + network = "10.0.48.0/20"
        },
    ]

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

calculated_tiers = [
  {
    "acl" = "public"
    "azs" = tomap({
      "a" = "10.0.0.0/24"
      "b" = "10.0.1.0/24"
      "c" = "10.0.2.0/24"
      "d" = "10.0.3.0/24"
    })
    "name" = "app"
    "network" = "10.0.0.0/20"
  },
  {
    "acl" = "private"
    "azs" = tomap({
      "a" = "10.0.16.0/24"
      "b" = "10.0.17.0/24"
      "c" = "10.0.18.0/24"
      "d" = "10.0.19.0/24"
    })
    "name" = "db"
    "network" = "10.0.16.0/20"
  },
  {
    "acl" = "private"
    "azs" = tomap({
      "a" = "10.0.32.0/24"
      "b" = "10.0.33.0/24"
      "c" = "10.0.34.0/24"
      "d" = "10.0.35.0/24"
    })
    "name" = "worker"
    "network" = "10.0.32.0/20"
  },
  {
    "acl" = "public"
    "azs" = tomap({
      "a" = "10.0.48.0/24"
      "b" = "10.0.49.0/24"
      "c" = "10.0.50.0/24"
      "d" = "10.0.51.0/24"
    })
    "name" = "lbs"
    "network" = "10.0.48.0/20"
  },
]
```
