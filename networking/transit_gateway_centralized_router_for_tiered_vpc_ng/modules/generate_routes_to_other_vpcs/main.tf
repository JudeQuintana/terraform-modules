/*
* # Generate Routes to Other VPCs Description
* See [Building a generate routes function using Terraform test](https://jq1.io/posts/generating_routes) blog post.
*
* This is a function type module (no resources) that will take a map of `tiered_vpc_ng` objects with [Tiered VPC-NG](https://github.com/JudeQuintana/terraform-modules/tree/master/networking/tiered_vpc_ng).
*
* It will create a map of routes to other VPC networks (execept itself) which will then be consumed by route resources.
*
* The `call` output is `toset([{ route_table_id = "rtb-12345678", destination_cidr_block = "x.x.x.x/x" }, ...])`.
*
* A list of route objects makes it easier to handle when passing to other route resource types (ie vpc, tgw) than a map of routes.
*
* ```hcl
* # snippet
* module "generate_routes_to_other_vpcs" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//utils/generate_routes_to_other_vpcs?ref=v1.4.16"
*
*   vpcs = var.vpcs
* }
*
* locals {
*   vpc_routes_to_other_vpcs = {
*     for this in module.generate_routes_to_other_vpcs.call :
*     format("|", this.route_table_id, this.destination_cidr_block) => this
*   }
* }
*
* resource "aws_route" "this" {
*   for_each = local.vpc_routes_to_other_vpcs
*
*   destination_cidr_block = each.value.destination_cidr_block
*   route_table_id         = each.value.route_table_id
*   transit_gateway_id     = aws_ec2_transit_gateway.this.id
*
*   # make sure the tgw route table is available first before the setting routes routes on the vpcs
*   depends_on = [aws_ec2_transit_gateway_route_table.this]
* }
* ```
*
* Example future use in [TGW Centralized Router](https://github.com/JudeQuintana/terraform-modules/blob/3be85f2cbd590fbb02dc9190213e0b9296388c56/networking/transit_gateway_centralized_router_for_tiered_vpc_ng/main.tf#L83-L113):
*
* You can still get the legacy map of routes with the `call_legacy` output.
*
* But I don’t think generating a map of routes with unique keys for the caller is not a shortcut worth taking becuase of it’s inflexibility when needing different transforms.
*
* The `call_legacy` output is `{ "rtb-id|route" => "route", ... }`. It has been deprecated in favor of `call`
*
* ```hcl
* # snippet
* module "generate_routes_to_other_vpcs" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//utils/generate_routes_to_other_vpcs?ref=v1.4.16"
*
*   vpcs = var.vpcs
* }
*
* resource "aws_route" "this" {
*   for_each = module.generate_routes_to_other_vpcs.call_legacy
*
*   destination_cidr_block = each.value
*   route_table_id         = split("|", each.key)[0]
*   transit_gateway_id     = aws_ec2_transit_gateway.this.id
*
*   # make sure the tgw route table is available first before the setting routes routes on the vpcs
*   depends_on = [aws_ec2_transit_gateway_route_table.this]
* }
* ```
*
* Run `terraform test` in the `./utils/generate_routes_to_other_vpcs` directory to run the test suite.
*
* The test suite will help when refactoring is needed.
*/
