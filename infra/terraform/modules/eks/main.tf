locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${local.name_prefix}-eks-cluster/cluster"
  retention_in_days = var.log_retention_days
}

resource "aws_eks_cluster" "this" {
    name = "${local.name_prefix}-eks-cluster"
    role_arn = aws_iam_role.this.arn
    version = var.version_number
    enabled_cluster_log_types = ["api", "audit", "authenticator"]
    access_config {
        authentication_mode = "API_AND_CONFIG_MAP"
        bootstrap_cluster_creator_admin_permissions = true
    }
    vpc_config {
        subnet_ids = var.subnet_ids
        endpoint_private_access = true
        endpoint_public_access  = true
    }
    depends_on = [
        aws_iam_role_policy_attachment.cluster_policy,
        aws_cloudwatch_log_group.cluster    
    ]
}

resource "aws_eks_node_group" "this" {
    cluster_name = aws_eks_cluster.this.name
    node_group_name = "${local.name_prefix}-eks-node-group"
    node_role_arn = aws_iam_role.node.arn
    subnet_ids = var.subnet_ids
    instance_types = ["t3.medium"]
    scaling_config {
        desired_size = 2
        max_size     = 3
        min_size     = 1
    }
    depends_on = [
        aws_iam_role_policy_attachment.node_worker,
        aws_iam_role_policy_attachment.cni_policy,
        aws_iam_role_policy_attachment.node_ecr
    ]
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "eks-pod-identity-agent"

  depends_on = [aws_eks_node_group.this]
}