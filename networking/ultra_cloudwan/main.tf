/*
*
* Idea: Ultra CloudWAN for Super Router
*
* Super Router provides scalable cross-region peering and routing between tgws and vpcs (no dx or vpn).
* ![super-router-base-architecture](https://jq1-io.s3.amazonaws.com/super-router/super-router-base-architecture.png)
*
* I was was thinking about building a cloudwan module to connect several super routers togther but only go thru cloudwan if the destination region is not one of the super router’s tgw pair (ie. us-west-2 <=> eu-central-1):
* ![ultra-cloudwan-init](https://jq1-io.s3.amazonaws.com/ultra-cloudwan/ultra-cloudwan-init.png)
*
*
* */
