 output "sns_topic_arn" {
  value = aws_sns_topic.this.arn
}

output "dashboard_url" {
  value = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.region}#dashboards:name=${aws_cloudwatch_dashboard.this.dashboard_name}"
}