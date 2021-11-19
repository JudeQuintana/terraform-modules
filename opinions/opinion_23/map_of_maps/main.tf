locals {
  map_of_maps = {
    name1 = {
      attribute1 = "name1-value1"
      attribute2 = "name1-value2"
      attribute3 = "name1-value3"
    }
    name2 = {
      attribute1 = "name2-value1"
      attribute2 = "name2-value2"
      attribute3 = "name2-value3"
    }
    name3 = {
      attribute1 = "name3-value1"
      attribute2 = "name3-value2"
      attribute3 = "name3-value3"
    }
  }
}

#  Then using local.map_of_maps to create a map of resource objects.
#
#  resource "some_resource" "this" {
#    for_each = local.map_of_maps
#
#    attribute1 = each.value.attribute1
#    attribute2 = each.value.attribute2
#    attribute3 = each.value.attribute3
#  }

locals {
  #  map_of_attribute1_value_to_name = {
  #    "name1-value1" = "name1"
  #    "name2-value1" = "name2"
  #    "name3-value1" = "name3"
  #  }
  map_of_attribute1_value_to_name = merge(
    [for k, v in local.map_of_maps :
      { for i in [values(v)[0]] : i => k }
    ]...
  )

  #  map_of_attribute1_value_to_object = {
  #    "name1-value1" = {
  #      "attribute1" = "name1-value1"
  #      "attribute2" = "name1-value2"
  #      "attribute3" = "name1-value3"
  #      "name" = "name1"
  #    }
  #    "name2-value1" = {
  #      "attribute1" = "name2-value1"
  #      "attribute2" = "name2-value2"
  #      "attribute3" = "name2-value3"
  #      "name" = "name2"
  #    }
  #    "name3-value1" = {
  #       "attribute1" = "name3-value1"
  #       "attribute2" = "name3-value2"
  #       "attribute3" = "name3-value3"
  #       "name" = "name3"
  #    }
  #  }
  map_of_attribute1_value_to_object = {
    for k, v in local.map_of_maps :
    v.attribute1 => {
      name       = k
      attribute1 = v.attribute1
      attribute2 = v.attribute2
      attribute3 = v.attribute3
    }
  }

  #  set_of_attribute1_values = toset([
  #    "name1-value1",
  #    "name2-value1",
  #    "name3-value1",
  #  ])
  set_of_attribute1_values = toset(
    [for k, v in local.map_of_maps : v.attribute1]
  )

  #  set_of_names = toset([
  #    "name1",
  #    "name2",
  #    "name3",
  #  ])
  set_of_names = toset(keys(local.map_of_maps))
}

output "map_of_attribute1_values_to_name" {
  value = local.map_of_attribute1_value_to_name
}

output "map_of_attribute_to_object" {
  value = local.map_of_attribute1_value_to_object
}

output "set_of_attribute1_values" {
  value = local.set_of_attribute1_values
}

output "set_of_names" {
  value = local.set_of_names
}
