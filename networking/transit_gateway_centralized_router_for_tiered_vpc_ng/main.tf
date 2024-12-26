/*
* # Transit Gateway Centralized Router
* - Creates hub and spoke topology from VPCs.
*
* `v1.9.3`
* - support for VPC centralized egress modes when passed to centralized router with validation
*   - when a VPC has `central = true` create `0.0.0.0/0` route on tgw route table
*   - when a VPC has `private = true` create `0.0.0.0/0` route on all private subnet route tables.
* - It is no longer required for a VPC's AZ to have a private or public subnet with `special = true` but
*   if there are subnets with `special = true` then it must be either 1 private or 1 public subnet that has it
*   configured per AZ (validation enforced).
* - Any VPC that has a private or public subnet with `special = true`, that subnet will be used as
*   the VPC attachment for it's AZ when passed to Centralized Router.
* - If the VPC does not have any AZs with private or public subnet with `special = true` it will be removed
*   from the Centralized Router.
*
* `v1.9.1`
* - ability to switch between a blackhole route and a static route that have the same cidr/ipv6_cidr for vpc attachments.
*
* `v1.9.0`
* - support for building IPv6 VPC routes for IPv6 secondary cidrs including variable validation.
* - updated generate_routes_to_vpcs module test suite with IPv6 VPC route tests.
* - build TGW static IPv4 and IPv6 routes for vpc attachments by default which is more ideal.
* - can now toggle route propagation for vpc attachments but disabled by default.
* - requires AWS provider version `>=5.61`
* - reorg filenames.
*
* `v1.8.2`
* - New [Dual Stack Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/dual_stack_networking_trifecta_demo)
* - Supports auto routing IPv4 secondary cidrs and IPv6 cidrs in addtion to IPv4 network cidrs
*   - Can blackhole IPv6 cidrs
*
* `v1.8.2` example:
* ```
* module "centralized_router" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/transit_gateway_centralized_router_for_tiered_vpc_ng?ref=v1.8.2"
*
*   env_prefix       = var.env_prefix
*   region_az_labels = var.region_az_labels
*   centralized_router = {
*     name            = "gambit"
*     amazon_side_asn = 64512
*     vpcs            = module.vpcs
*     blackhole = {
*       cidrs      = ["172.16.8.0/24"]
*       ipv6_cidrs = ["2600:1f24:66:c109::/64"]
*     }
*   }
* }
* ```
*
* `v1.8.1`
* - Now supports VPC attachments for private subnets.
*   - Uses the subnet id for a subnet tagged with `special = true` from either a private or a public subnet per AZ in Tiered VPC-NG for `v1.8.1`
*   - Will continue work with Super Router, Full Mesh Trio and Mega Mesh at `v1.8.0`.
*
* `v1.8.1` Example (same as before but with source change):
* ```
* module "centralized_router" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/transit_gateway_centralized_router_for_tiered_vpc_ng?ref=v1.8.1"
*
*   env_prefix       = var.env_prefix
*   region_az_labels = var.region_az_labels
*   centralized_router = {
*     name            = "bishop"
*     amazon_side_asn = 64512
*     vpcs            = module.vpcs
*     blackhole_cidrs = ["172.16.8.0/24"]
*   }
* }
* ```
*
* `v1.8.0`
* - This Transit Gateway Centralized Router module will create a hub spoke and topology from existing Tiered VPCs.
* - Will use the special public subnet in each AZ when a Tiered VPC is passed to it.
* - All attachments will be associated and routes propagated to one TGW Route Table.
* - Each Tiered VPC will have all their route tables updated in each VPC with a route to all other VPC networks via the TGW.
* - Will generate and add routes in each VPC to all other networks.
*
* `v1.8.0` Example:
* ```
* module "centralized_router" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/transit_gateway_centralized_router_for_tiered_vpc_ng?ref=v1.8.0"
*
*   env_prefix       = var.env_prefix
*   region_az_labels = var.region_az_labels
*   centralized_router = {
*     name            = "bishop"
*     amazon_side_asn = 64512
*     blackhole_cidrs = ["172.16.8.0/24"]
*     vpcs            = module.vpcs
*   }
* }
* ```
*
* # Networking Trifecta Demo
* Blog Post:
* [Terraform Networking Trifecta ](https://jq1.io/posts/tnt/)
*
* Main:
* - [Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/networking_trifecta_demo)
*   - See [Trifecta Demo Time](https://jq1.io/posts/tnt/#trifecta-demo-time) for instructions.
*
*/
