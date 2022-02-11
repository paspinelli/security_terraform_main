variable "environment" {
  description = "Environment that is being used"
}

variable "business_unit" {
  description = "Business unit that this resource belongs to"
}

variable "owner" {
  description = "Team that this resource belongs to"
}

variable "name" {
  description = "Product's Name"
}

variable "profile" {
  description = "Profile of the aws profile to use for the deployment (should correspond to the environment)"
}

variable "region" {
  description = "Region where the resources are going to be created"
}

variable "country" {
  description = "country"
}

variable "assume_role_arn" {
  description = "ARN rol who is going to assume on atlantis"
}

variable "profile_ops" {}

variable "bucket_tfstate" {}

variable "vpc_tfstate_key" {}

variable "sg_tfstate_key" {}

variable "rds_tfstate_key" {}

variable "dynamodb_tfstate_table" {}
