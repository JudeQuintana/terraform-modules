# Terraform Opinion #23: Use list of objects over map of maps.

See the [blog post](https://jq1.io/posts/opinion_23) for more details.

Use `terraform apply -refresh-only` in each directory to show the same collection types output below for `list_of_objects` and `map_of_maps`.

```
map_of_attribute1_value_to_name = {
  "name1-value1" = "name1"
  "name2-value1" = "name2"
  "name3-value1" = "name3"
}
map_of_attribute_value_to_object = {
  "name1-value1" = {
    "attribute1" = "name1-value1"
    "attribute2" = "name1-value2"
    "attribute3" = "name1-value3"
    "name" = "name1"
  }
  "name2-value1" = {
    "attribute1" = "name2-value1"
    "attribute2" = "name2-value2"
    "attribute3" = "name2-value3"
    "name" = "name2"
  }
  "name3-value1" = {
    "attribute1" = "name3-value1"
    "attribute2" = "name3-value2"
    "attribute3" = "name3-value3"
    "name" = "name3"
  }
}
set_of_attribute1_values = toset([
  "name1-value1",
  "name2-value1",
  "name3-value1",
])
set_of_names = toset([
  "name1",
  "name2",
  "name3",
])
```
