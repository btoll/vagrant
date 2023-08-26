terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "3.55.0"
        }
    }
}

/*
provider "aws" {
    profile = "default"
    region  = "us-west-2"
}
*/

data "aws_availability_zones" "available" {
    state = "available"
}

