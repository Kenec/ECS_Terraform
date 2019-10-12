resource "aws_ecs_cluster" "paystack-ecs-cluster" {
  name = "paystack-cluster"
}

data "aws_ecs_task_definition" "paystack-task-definintion" {
  task_definition = "${aws_ecs_task_definition.paystack-task-definintion.family}"
  depends_on = ["aws_ecs_task_definition.paystack-task-definintion"]
}

data "template_file" "paystack_task" {
  template = "${file("templates/ecs/paystack.json.tpl")}"

  vars = {
    app_image = "${var.app_image}"
    mongo_uri = "${var.mongo_uri}"
    redis_uri  = "${var.redis_uri}"
    mongo_uri_local = "${var.mongo_uri}"
    redis_uri_local  = "${var.redis_uri}"
  }

}

resource "aws_ecs_task_definition" "paystack-task-definintion" {
  family = "paystack-service"

  container_definitions = "${data.template_file.paystack_task.rendered}"
}

resource "aws_ecs_service" "paystack-ecs-service" {
  name = "paystack-service"
  cluster = "${aws_ecs_cluster.paystack-ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.paystack-task-definintion.family}:${max("${aws_ecs_task_definition.paystack-task-definintion.revision}", "${data.aws_ecs_task_definition.paystack-task-definintion.revision}")}"
  desired_count = 1
  iam_role = "${aws_iam_role.ecs-service-role.name}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.paystack-alb-tg.id}"
    container_name = "paystack-app"
    container_port = "3000"
  }

  depends_on = [
  # "aws_iam_role_policy.ecs-service",
  "aws_alb_listener.front_end",
  ]
}
