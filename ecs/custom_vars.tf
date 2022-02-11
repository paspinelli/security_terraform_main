variable "cpu" {}

variable "memory" {}

variable "db_port" {}

variable "db_user" {}

variable "celery_user" {}

variable "uwsgi_processes" {}

variable "uwsgi_threads" {}

variable "celery_worker_type" {}

variable "celery_autoscale_min" {}

variable "celery_autoscale_max" {}

variable "celery_concurrency" {}

variable "celery_prefetch_multiplier" {}

variable "log_retention_days" {}

variable "service_count" {}

variable "forti_cidr_block" {}

variable "ssm_db_password" {}

variable "ssm_celery_password" {}

variable "ssm_secret_key" {}
