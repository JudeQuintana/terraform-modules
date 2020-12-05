# Overview

Used to generate tiered subnets for a VPC. Please see my [Tiered Subnet
Calculator](https://jq1.io/posts/tiered_subnet_calculator/) blog post for a more detailed explanation.

# Usage
`tiers.auto.tfvars`
```
vpc_cidr_block = "10.0.0.0/16"

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


`terraform refresh`
```
$ terraform refresh

Empty or non-existent state file.

Refresh will do nothing. Refresh does not error or return an erroneous
exit status because many automation scripts use refresh, plan, then apply
and may not have a state file yet for the first run.


Outputs:

calculated_tiers = [
  {
    "acl" = "public"
    "azs" = {
      "a" = "10.0.0.0/24"
      "b" = "10.0.1.0/24"
      "c" = "10.0.2.0/24"
      "d" = "10.0.3.0/24"
    }
    "name" = "app"
    "network" = "10.0.0.0/20"
  },
  {
    "acl" = "private"
    "azs" = {
      "a" = "10.0.16.0/24"
      "b" = "10.0.17.0/24"
      "c" = "10.0.18.0/24"
      "d" = "10.0.19.0/24"
    }
    "name" = "db"
    "network" = "10.0.16.0/20"
  },
  {
    "acl" = "private"
    "azs" = {
      "a" = "10.0.32.0/24"
      "b" = "10.0.33.0/24"
      "c" = "10.0.34.0/24"
      "d" = "10.0.35.0/24"
    }
    "name" = "worker"
    "network" = "10.0.32.0/20"
  },
  {
    "acl" = "public"
    "azs" = {
      "a" = "10.0.48.0/24"
      "b" = "10.0.49.0/24"
      "c" = "10.0.50.0/24"
      "d" = "10.0.51.0/24"
    }
    "name" = "lbs"
    "network" = "10.0.48.0/20"
  },
]
```

