variable "region" {
  default = "us-east-2"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "tenancy" {
  default = "default"
}

variable "private_subnet" {
  default = "10.0.2.0/24"
}

variable "public_subnet" {
  default = "10.0.1.0/24"
}

variable "public_subnet2" {
  default = "10.0.3.0/24"
}

variable "ec2_cpu" {
  default = "1024"
}

variable "ec2_memory" {
  default = "2048"
}

variable "app_port" {
  default = "3000"
}

variable "host_port" {
  default = "0"
}


variable "app_image" {
  default     = ""
}

variable "mongo_uri" {}

variable "redis_uri" {}



variable "ecs_task_execution_role_name" {
  default = "PaystackEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
  default = "PaystackEcsAutoScaleRole"
}

variable "health_check_path" {
  default = "/"
}








