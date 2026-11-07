locals {
  name_prefix = "${var.project_name}-${var.environment}"

  alarm_actions = [aws_sns_topic.this.arn]

  # Valkey publishes metrics per node: <replication-group-id>-001, -002, ...
  valkey_node_ids = [
    for i in range(1, var.valkey_num_nodes + 1) :
    format("%s-%03d", var.valkey_replication_group_id, i)
  ]
}

data "aws_region" "current" {}


resource "aws_sns_topic" "this" {
  name = "${local.name_prefix}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_iam_role" "cloudwatch_agent" {
  name = "${local.name_prefix}-cloudwatch-agent"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.cloudwatch_agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name                = var.cluster_name
  addon_name                  = "amazon-cloudwatch-observability"
  resolve_conflicts_on_create = "OVERWRITE"

  pod_identity_association {
    role_arn        = aws_iam_role.cloudwatch_agent.arn
    service_account = "cloudwatch-agent"
  }

  depends_on = [aws_iam_role_policy_attachment.cloudwatch_agent]
}

# ---------------------------------------------------------------------------
# EKS alarms (ContainerInsights metrics)
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "eks_node_cpu" {
  alarm_name          = "${local.name_prefix}-eks-node-cpu"
  alarm_description   = "EKS node CPU above ${var.cpu_threshold}%"
  namespace           = "ContainerInsights"
  metric_name         = "node_cpu_utilization"
  dimensions          = { ClusterName = var.cluster_name }
  statistic           = "Average"
  period              = 120
  evaluation_periods  = 5
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cpu_threshold
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "eks_node_memory" {
  alarm_name          = "${local.name_prefix}-eks-node-memory"
  alarm_description   = "EKS node memory above ${var.memory_threshold}%"
  namespace           = "ContainerInsights"
  metric_name         = "node_memory_utilization"
  dimensions          = { ClusterName = var.cluster_name }
  statistic           = "Average"
  period              = 120
  evaluation_periods  = 5
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.memory_threshold
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "eks_failed_nodes" {
  alarm_name          = "${local.name_prefix}-eks-failed-nodes"
  alarm_description   = "One or more EKS nodes are failing"
  namespace           = "ContainerInsights"
  metric_name         = "cluster_failed_node_count"
  dimensions          = { ClusterName = var.cluster_name }
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 3
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${local.name_prefix}-rds-cpu"
  alarm_description   = "RDS MySQL CPU above ${var.cpu_threshold}%"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  dimensions          = { DBInstanceIdentifier = var.rds_instance_id }
  statistic           = "Average"
  period              = 120
  evaluation_periods  = 5
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cpu_threshold
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  alarm_name          = "${local.name_prefix}-rds-free-storage"
  alarm_description   = "RDS MySQL free storage below ${var.rds_free_storage_gb} GB"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  dimensions          = { DBInstanceIdentifier = var.rds_instance_id }
  statistic           = "Minimum"
  period              = 300
  evaluation_periods  = 3
  comparison_operator = "LessThanThreshold"
  threshold           = var.rds_free_storage_gb * 1024 * 1024 * 1024
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

# DocumentDB alarms
resource "aws_cloudwatch_metric_alarm" "docdb_cpu" {
  alarm_name          = "${local.name_prefix}-docdb-cpu"
  alarm_description   = "DocumentDB CPU above ${var.cpu_threshold}%"
  namespace           = "AWS/DocDB"
  metric_name         = "CPUUtilization"
  dimensions          = { DBClusterIdentifier = var.docdb_cluster_id }
  statistic           = "Average"
  period              = 120
  evaluation_periods  = 5
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cpu_threshold
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

# Valkey alarms

resource "aws_cloudwatch_metric_alarm" "valkey_cpu" {
  for_each = toset(local.valkey_node_ids)

  alarm_name          = "${local.name_prefix}-valkey-cpu-${each.value}"
  alarm_description   = "Valkey engine CPU above ${var.cpu_threshold}% on ${each.value}"
  namespace           = "AWS/ElastiCache"
  metric_name         = "EngineCPUUtilization"
  dimensions          = { CacheClusterId = each.value }
  statistic           = "Average"
  period              = 120
  evaluation_periods  = 5
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cpu_threshold
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "valkey_memory" {
  for_each = toset(local.valkey_node_ids)

  alarm_name          = "${local.name_prefix}-valkey-memory-${each.value}"
  alarm_description   = "Valkey memory above ${var.memory_threshold}% on ${each.value}"
  namespace           = "AWS/ElastiCache"
  metric_name         = "DatabaseMemoryUsagePercentage"
  dimensions          = { CacheClusterId = each.value }
  statistic           = "Average"
  period              = 120
  evaluation_periods  = 5
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.memory_threshold
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "valkey_evictions" {
  for_each = toset(local.valkey_node_ids)

  alarm_name          = "${local.name_prefix}-valkey-evictions-${each.value}"
  alarm_description   = "Valkey is evicting keys (carts may be lost) on ${each.value}"
  namespace           = "AWS/ElastiCache"
  metric_name         = "Evictions"
  dimensions          = { CacheClusterId = each.value }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

# Amazon MQ alarms

resource "aws_cloudwatch_metric_alarm" "mq_queue_backlog" {
  alarm_name          = "${local.name_prefix}-mq-queue-backlog"
  alarm_description   = "Orders piling up in RabbitMQ (dispatch may be down)"
  namespace           = "AWS/AmazonMQ"
  metric_name         = "MessageCount"
  dimensions          = { Broker = var.mq_broker_name }
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 2
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.mq_backlog_threshold
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

# Dashboard
resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${local.name_prefix}-overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "EKS nodes - CPU and memory %"
          region = data.aws_region.current.region
          stat   = "Average"
          period = 300
          metrics = [
            ["ContainerInsights", "node_cpu_utilization", "ClusterName", var.cluster_name],
            ["ContainerInsights", "node_memory_utilization", "ClusterName", var.cluster_name],
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Database CPU %"
          region = data.aws_region.current.region
          stat   = "Average"
          period = 300
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id],
            ["AWS/DocDB", "CPUUtilization", "DBClusterIdentifier", var.docdb_cluster_id],
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Valkey memory %"
          region = data.aws_region.current.region
          stat   = "Average"
          period = 300
          metrics = [
            for id in local.valkey_node_ids :
            ["AWS/ElastiCache", "DatabaseMemoryUsagePercentage", "CacheClusterId", id]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "RabbitMQ messages waiting"
          region = data.aws_region.current.region
          stat   = "Maximum"
          period = 300
          metrics = [
            ["AWS/AmazonMQ", "MessageCount", "Broker", var.mq_broker_name],
          ]
        }
      },
    ]
  })
}

# Cost alert
resource "aws_budgets_budget" "monthly" {
  count = var.enable_budget ? 1 : 0

  name         = "${local.name_prefix}-monthly-budget"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}