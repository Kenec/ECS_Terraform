resource "aws_alb_target_group" "paystack-alb-tg" {
  name = "paystack-alb-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_alb" "main" {
  name = "paystack-alb-ecs"
  subnets = ["${aws_subnet.public.id}", "${aws_subnet.public2.id}"]
  security_groups = ["${aws_security_group.lb.id}"]
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.paystack-alb-tg.id}"
    type = "forward"
  }
}