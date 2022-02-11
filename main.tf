terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.region
  assume_role {
   role_arn = var.assume_role_arn
  }
}

data "aws_region" "current_region" {}

data "aws_caller_identity" "current_caller" {}