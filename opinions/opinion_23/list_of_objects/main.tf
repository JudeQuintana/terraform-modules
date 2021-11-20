locals {
  list_of_objects = [
    {
      name       = "name1"
      attribute1 = "name1-value1"
      attribute2 = "name1-value2"
      attribute3 = "name1-value3"
    },
    {
      name       = "name2"
      attribute1 = "name2-value1"
      attribute2 = "name2-value2"
      attribute3 = "name2-value3"
    },
    {
      name       = "name3"
      attribute1 = "name3-value1"
      attribute2 = "name3-value2"
      attribute3 = "name3-value3"
    }
  ]
}

#  Then using local.list_of_objects to create a map of resource objects.
#
#  resource "some_resource" "this" {
#    for_each = { for r in local.list_of_objects : r.name => r }
#
#    attribute1 = each.value.attribute1
#    attribute2 = each.value.attribute2
#    attribute3 = each.value.attribute3
#  }

locals {
  map_of_attribute1_value_to_name   = zipmap(local.list_of_objects[*].attribute1, local.list_of_objects[*].name)
  map_of_attribute1_value_to_object = { for o in local.list_of_objects : o.attribute1 => o }
  set_of_attribute1_values          = toset(local.list_of_objects[*].attribute1)
  set_of_names                      = toset(local.list_of_objects[*].name)
}

output "map_of_attribute1_value_to_name" {
  value = local.map_of_attribute1_value_to_name
}

output "map_of_attribute_value_to_object" {
  value = local.map_of_attribute1_value_to_object
}

output "set_of_attribute1_values" {
  value = local.set_of_attribute1_values
}

output "set_of_names" {
  value = local.set_of_names
}

# getting to a map of maps is just as easy.
# output "map_of_maps" {
#   value = {
#     for o in local.list_of_objects : o.name => {
#       attribute1 = o.attribute1
#       attribute2 = o.attribute2
#       attribute3 = o.attribute3
#     }
#   }
# }
