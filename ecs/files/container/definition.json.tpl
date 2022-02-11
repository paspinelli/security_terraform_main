[
    {
        "image": "defectdojo/defectdojo-nginx:latest",
        "name": "nginx",
        "dependsOn": [
            {
                "condition": "START",
                "containerName": "uwsgi"
            }
        ],
        "essential": true,
        "portMappings": [
            {
                "containerPort": 8080,
                "protocol": "tcp"
            }
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-region": "${region}",
                "awslogs-group": "${log_group}",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "environment": [
            {
                "name": "DD_UWSGI_HOST",
                "value": "127.0.0.1"
            }
        ]
    },
    {
        "image": "defectdojo/defectdojo-django:latest",
        "name": "uwsgi",
        "essential": true,
        "entryPoint": [
            "/entrypoint-uwsgi.sh"
        ],
        "portMappings": [
            {
                "containerPort": 3031,
                "protocol": "tcp"
            }
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-region": "${region}",
                "awslogs-group": "${log_group}",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "environment": [
            {
                "name": "DD_SECRET_KEY",
                "value": "${secret_key}"
            },
            {
                "name": "DD_DEBUG",
                "value": "off"
            },
            {
                "name": "DD_ALLOWED_HOSTS",
                "value": "*"
            },
            {
                "name": "DD_DATABASE_URL",
                "value": "${db_url}"
            },
            {
                "name": "DD_DATABASE_PORT",
                "value": "${db_port}"
            },
            {
                "name": "DD_DATABASE_ENGINE",
                "value": "django.db.backends.mysql"
            },
            {
                "name": "DD_CELERY_BROKER_USER",
                "value": "${celery_user}"
            },
            {
                "name": "DD_CELERY_BROKER_PASSWORD",
                "value": "${celery_password}"
            },
            {
                "name": "DD_UWSGI_NUM_OF_PROCESSES",
                "value": "${uwsgi_processes}"
            },
            {
                "name": "DD_UWSGI_NUM_OF_THREADS",
                "value": "${uwsgi_threads}"
            }
        ]
    },
    {
        "image": "defectdojo/defectdojo-django:latest",
        "name": "celerybeat",
        "dependsOn": [
            {
                "condition": "START",
                "containerName": "rabbitmq"
            }
        ],
        "essential": true,
        "entryPoint": [
            "/entrypoint-celery-beat.sh"
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-region": "${region}",
                "awslogs-group": "${log_group}",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "environment": [
            {
                "name": "DD_SECRET_KEY",
                "value": "${secret_key}"
            },
            {
                "name": "DD_DATABASE_URL",
                "value": "${db_url}"
            },
            {
                "name": "DD_DATABASE_PORT",
                "value": "${db_port}"
            },
            {
                "name": "DD_DATABASE_ENGINE",
                "value": "django.db.backends.mysql"
            },
            {
                "name": "DD_CELERY_BROKER_USER",
                "value": "${celery_user}"
            },
            {
                "name": "DD_CELERY_BROKER_PASSWORD",
                "value": "${celery_password}"
            },
            {
                "name": "DD_CELERY_BROKER_HOST",
                "value": "127.0.0.1"
            }
        ]
    },
    {
        "image": "defectdojo/defectdojo-django:latest",
        "name": "celeryworker",
        "dependsOn": [
            {
                "condition": "START",
                "containerName": "rabbitmq"
            }
        ],
        "essential": true,
        "entryPoint": [
            "/entrypoint-celery-worker.sh"
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-region": "${region}",
                "awslogs-group": "${log_group}",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "environment": [
            {
                "name": "DD_SECRET_KEY",
                "value": "${secret_key}"
            },
            {
                "name": "DD_DATABASE_URL",
                "value": "${db_url}"
            },
            {
                "name": "DD_DATABASE_PORT",
                "value": "${db_port}"
            },
            {
                "name": "DD_DATABASE_ENGINE",
                "value": "django.db.backends.mysql"
            },
            {
                "name": "DD_CELERY_BROKER_USER",
                "value": "${celery_user}"
            },
            {
                "name": "DD_CELERY_BROKER_PASSWORD",
                "value": "${celery_password}"
            },
            {
                "name": "DD_CELERY_BROKER_HOST",
                "value": "127.0.0.1"
            },
            {
                "name": "DD_CELERY_WORKER_POOL_TYPE",
                "value": "${celery_worker_type}"
            },
            {
                "name": "DD_CELERY_WORKER_AUTOSCALE_MIN",
                "value": "${celery_autoscale_min}"
            },
            {
                "name": "DD_CELERY_WORKER_AUTOSCALE_MAX",
                "value": "${celery_autoscale_max}"
            },
            {
                "name": "DD_CELERY_WORKER_CONCURRENCY",
                "value": "${celery_concurrency}"
            },
            {
                "name": "DD_CELERY_WORKER_PREFETCH_MULTIPLIER",
                "value": "${celery_prefetch_multiplier}"
            }
        ]
    },
    {
        "image": "defectdojo/defectdojo-django:latest",
        "name": "initializer",
        "dependsOn": [
            {
                "condition": "START",
                "containerName": "rabbitmq"
            }
        ],
        "essential": false,
        "entryPoint": [
            "/entrypoint-initializer.sh"
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-region": "${region}",
                "awslogs-group": "${log_group}",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "environment": [
            {
                "name": "DD_SECRET_KEY",
                "value": "${secret_key}"
            },
            {
                "name": "DD_DATABASE_URL",
                "value": "${db_url}"
            },
            {
                "name": "DD_DATABASE_PORT",
                "value": "${db_port}"
            },
            {
                "name": "DD_ADMIN_USER",
                "value": "admin"
            },
            {
                "name": "DD_ADMIN_MAIL",
                "value": "admin@defectdojo.local"
            },
            {
                "name": "DD_ADMIN_FIRST_NAME",
                "value": "Admin"
            },
            {
                "name": "DD_ADMIN_LAST_NAME",
                "value": "User"
            },
            {
                "name": "DD_INITIALIZE",
                "value": "true"
            }
        ]
    },
    {
        "image": "rabbitmq:3.7",
        "name": "rabbitmq",
        "essential": true,
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-region": "${region}",
                "awslogs-group": "${log_group}",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "environment": [
            {
                "name": "RABBITMQ_DEFAULT_USER",
                "value": "${celery_user}"
            },
            {
                "name": "RABBITMQ_DEFAULT_PASS",
                "value": "${celery_password}"
            }
        ],
        "portMappings": [
            {
                "containerPort": 5672,
                "protocol": "tcp"
            }
        ]
    }
]
