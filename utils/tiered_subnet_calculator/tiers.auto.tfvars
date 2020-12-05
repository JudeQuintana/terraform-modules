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

