/*
* # Transit Gateway Centralized Router Description
* - This Transit Gateway Centralized Router module will use the first public subnet in the list for each AZ of that VPC for the VPC attachments to all AZs.
* - All attachments will be associated and routes propagated to one TGW Route Table.
* - Each Tiered VPC will have all their route tables updated in each VPC with a route to all other VPC networks via the TGW.
* - Will generate and add routes in each VPC to all other networks.
*
* Example:
* ```
* module "centralized_router" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/transit_gateway_centralized_router_for_tiered_vpc_ng?ref=v1.4.9"
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
  * - See [Trifecta Demo Time](https://jq1.io/posts/tnt/#trifecta-demo-time) for instructions.
*
*/
