# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "paystack_log_group" {
  name              = "/ecs/paystack-app"
  retention_in_days = 30

  tags = {
    Name = "paystack-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "paystack_log_stream" {
  name           = "paystack-log-stream"
  log_group_name = "${aws_cloudwatch_log_group.paystack_log_group.name}"
}