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

data "terraform_remote_state" "rds-security" {
  backend = "s3"
  config = {
    profile        = var.profile_ops
    region         = var.region
    bucket         = var.bucket_tfstate
    key            = var.rds_tfstate_key
    dynamodb_table = var.dynamodb_tfstate_table
    encrypt        = true
  }
}

resource "aws_ecs_cluster" "cluster" {
  name               = "${var.name}-${var.environment}-ecs-cluster"
  capacity_providers = ["FARGATE"]

  tags = {
    Name          = title(var.name)
    Owner         = title(var.owner)
    Environment   = title(var.environment)
    Business_unit = title(var.business_unit)
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.name}-${var.environment}-ecs-task-execution-role"
  assume_role_policy = file("${path.module}/files/iam/ecs_task_execution_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "td" {

  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile(
    "${path.module}/files/container/definition.json.tpl",
    {
      secret_key                 = local.secret_key,
      db_url                     = local.db_url,
      db_port                    = var.db_port,
      celery_user                = var.celery_user,
      celery_password            = local.celery_password,
      uwsgi_processes            = var.uwsgi_processes,
      uwsgi_threads              = var.uwsgi_threads,
      celery_worker_type         = var.celery_worker_type,
      celery_autoscale_min       = var.celery_autoscale_min,
      celery_autoscale_max       = var.celery_autoscale_max,
      celery_concurrency         = var.celery_concurrency,
      celery_prefetch_multiplier = var.celery_prefetch_multiplier,
      log_group                  = local.log_group,
      region                     = var.region
    }
  )

  tags = {
    Name          = title(var.name)
    Owner         = title(var.owner)
    Environment   = title(var.environment)
    Business_unit = title(var.business_unit)
  }
}

resource "aws_cloudwatch_log_group" "cw_container_log" {
  name              = local.log_group
  retention_in_days = var.log_retention_days

  tags = {
    Name          = title(var.name)
    Owner         = title(var.owner)
    Environment   = title(var.environment)
    Business_unit = title(var.business_unit)
  }
}

resource "aws_ecs_service" "service" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.td.arn
  desired_count   = var.service_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = local.private_subnets
    security_groups  = [local.sg_id]
    assign_public_ip = false
  }

  tags = {
    Name          = title(var.name)
    Owner         = title(var.owner)
    Environment   = title(var.environment)
    Business_unit = title(var.business_unit)
  }
}

resource "aws_security_group_rule" "vpn" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [var.forti_cidr_block]
  security_group_id = local.sg_id
}

resource "aws_security_group_rule" "self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = local.sg_id
}

locals {
  private_subnets = data.terraform_remote_state.vpc-arg-security.outputs.private_subnets
  sg_id           = data.terraform_remote_state.sg-arg-security.outputs.sg_id
  db_endpoint     = data.terraform_remote_state.rds-arg-security.outputs.endpoint
  log_group       = join("", ["/ecs/", var.name])
  db_url          = join("", ["mysql://", var.db_user, ":", local.db_password, "@", local.db_endpoint, "/", var.name])
  secret_key      = data.aws_ssm_parameter.secret_key.value
  celery_password = data.aws_ssm_parameter.celery_password.value
  db_password     = data.aws_ssm_parameter.db_password.value
}

data "aws_ssm_parameter" "db_password" {
  name = var.ssm_db_password
}

data "aws_ssm_parameter" "celery_password" {
  name = var.ssm_celery_password
}

data "aws_ssm_parameter" "secret_key" {
  name = var.ssm_secret_key
}
