data "terraform_remote_state" "vpc-security" {
  backend = "s3"
  config = {
    profile        = var.profile_ops
    region         = var.region
    bucket         = var.bucket_tfstate
    key            = var.vpc_tfstate_key
    dynamodb_table = var.dynamodb_tfstate_table
    encrypt        = true
  }
}

data "terraform_remote_state" "sg-security" {
  backend = "s3"
  config = {
    profile        = var.profile_ops
    region         = var.region
    bucket         = var.bucket_tfstate
    key            = var.sg_tfstate_key
    dynamodb_table = var.dynamodb_tfstate_table
    encrypt        = true
  }
}

data "aws_ssm_parameter" "db_password" {
  name = var.ssm_db_password
}

locals {
  vpc_id          = data.terraform_remote_state.vpc-arg-security.outputs.vpc_id
  private_subnets = data.terraform_remote_state.vpc-arg-security.outputs.private_subnets
  sg_id           = data.terraform_remote_state.sg-arg-security.outputs.sg_id
  db_password     = data.aws_ssm_parameter.db_password.value
}

module "rds" {
  source = "REPOSITORY"

  name          = var.name
  db_name       = var.name
  environment   = var.environment
  business_unit = var.business_unit
  owner         = var.owner

  vpc_id          = local.vpc_id
  cidr_block      = null
  private_subnets = local.private_subnets

  engine                = var.db_engine
  engine_version        = var.db_version
  port                  = var.db_port
  instance_class        = var.db_instance_type
  storage_type          = var.storage_type
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage


  credentials = {
    username = var.db_user
    password = local.db_password
  }

  deletion_protection     = var.deletion_protection
  apply_immediately       = var.apply_immediately
  backup_retention_period = var.backup_retention_period

  ingress_from_security_group = [local.sg_id]
  security_group_name         = "${var.name}-db-sg"
  security_group_description  = "Security group for ${var.name} database"

  db_instance_identifier     = var.name
  auto_minor_version_upgrade = true
  subnet_group_name          = var.name
  publicly_accessible        = false

  parameter_family = "mysql8.0"
}
