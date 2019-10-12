resource "aws_launch_configuration" "ecs-launch-configuration" {
  name = "ecs-launch-configuration"
  image_id = "ami-0918be4c91697b460"
  instance_type = "t2.medium"
  iam_instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.id}"

  root_block_device {
    volume_type = "standard"
    volume_size = 100
    delete_on_termination = true
  }

  security_groups = ["${aws_security_group.ec2.id}"]

  lifecycle {
    create_before_destroy = false
  }

  associate_public_ip_address = true
  key_name = "testone"

#
# register the cluster name with ecs-agent which will in turn coord
# with the AWS api about the cluster
#
user_data = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.paystack-ecs-cluster.name} > /etc/ecs/ecs.config\nstart ecs"

}
resource "null_resource" "apply" {

  depends_on = [
    "aws_ecs_task_definition.paystack-task-definintion",
    "aws_ecs_service.paystack-ecs-service",
  ]

  provisioner "local-exec" {
    command = "aws ecs run-task --cluster ${aws_ecs_cluster.paystack-ecs-cluster.arn} --task-definition ${aws_ecs_task_definition.paystack-task-definintion.arn}"
  }
}