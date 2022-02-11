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

locals {
    vpc_id = data.terraform_remote_state.vpc-security.outputs.vpc_id
}

resource "aws_security_group" "sg" {
  name        = "${var.name}-service-sg"
  description = "Security group for ${var.name} service"
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #tfsec:ignore:AWS009
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = title(var.name)
    Owner         = title(var.owner)
    Environment   = title(var.environment)
    Business_unit = title(var.business_unit)
  }
}