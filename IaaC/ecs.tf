# Create ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "paystack-cluster"
}

# ECS Template file
data "template_file" "paystack_app" {
  template = "${file("./templates/ecs/ecs_config.tpl")}"

  vars = {
    app_image      = "${var.app_image}"
    app_port       = "${var.app_port}"
    ec2_cpu        = "${var.ec2_cpu}"
    ec2_memory     = "${var.ec2_memory}"
    aws_region     = "${var.region}"
  }
}

# Create task definition
resource "aws_ecs_task_definition" "paystack_app" {
  family                   = "paystack-app-task"
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.ec2_cpu}"
  memory                   = "${var.ec2_memory}"
  container_definitions    = "${data.template_file.paystack_app.rendered}"
}

# Create Cluster Service
resource "aws_ecs_service" "main" {
  name            = "paystack-cluster-service"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.paystack_app.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.ecs_tasks.id}"]
    subnets          = ["${aws_subnet.public.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.arn}"
    container_name   = "paystack-app"
    container_port   = "${var.app_port}"
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
  #depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]
}

# ECS Template file
data "template_file" "network_config" {
  template = "${file("./templates/ecs/network_config.json.tpl")}"

  vars = {
    subnets1 = "${aws_subnet.public.id}"
    lb_sg  = "${aws_security_group.lb.name}"
  }
}

# Run Task
# resource "null_resource" "apply" {

#   depends_on = [
#     "aws_ecs_task_definition.paystack_app",
#     "aws_ecs_service.main",
#   ]

#   provisioner "local-exec" {
#     command = "aws ecs run-task --cluster ${aws_ecs_cluster.main.arn} --task-definition ${aws_ecs_task_definition.paystack_app.arn}"
#   }
# }

