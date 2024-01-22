terraform {
  required_version = ">=1.3"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">=4.20"
      configuration_aliases = [aws.one, aws.two, aws.three, aws.four, aws.five, aws.six, aws.seven, aws.eight, aws.nine, aws.ten]
    }
  }
}
