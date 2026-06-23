resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  alarm_description = "Alarm when CPU exceeds 70%"

  dimensions = {
    InstanceId = aws_instance.web_server.id
  }

  alarm_actions = [
    aws_sns_topic.ec2_alerts.arn
  ]
}