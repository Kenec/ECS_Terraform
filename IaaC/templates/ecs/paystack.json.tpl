[ 
  { 
    "name": "paystack-app", 
    "image": "${app_image}", 
    "memory": 128, 
    "cpu": 128, 
    "essential": true, 
    "portMappings": [ {
      "hostPort": 0, 
      "containerPort": 3000, 
      "protocol": "tcp" 
    } ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/paystack-app",
        "awslogs-region": "us-east-2",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "environment": [{
      "name": "MONGODB_URI",
      "value": "${mongo_uri}"
    },
    {
      "name": "REDIS_URI",
      "value": "${redis_uri}"
    },
    {
      "name": "MONGODB_URI_LOCAL",
      "value": "${mongo_uri}"
    },
    {
      "name": "REDIS_URI_LOCAL",
      "value": "${redis_uri}"
    }]
  } 
]