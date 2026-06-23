# SNS Topic for EC2 Monitoring Alerts
resource "aws_sns_topic" "ec2_alerts" {
  name = "ec2-monitoring-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.ec2_alerts.arn
  protocol  = "email"
  endpoint  = "priyamalewadkar@gmail.com"
}