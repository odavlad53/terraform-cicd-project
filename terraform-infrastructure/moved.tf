# ECS resources
moved {
  from = aws_ecs_cluster.this
  to   = module.ecs.aws_ecs_cluster.this
}

moved {
  from = aws_ecs_task_definition.this
  to   = module.ecs.aws_ecs_task_definition.this
}

moved {
  from = aws_ecs_service.this
  to   = module.ecs.aws_ecs_service.this
}

moved {
  from = aws_kms_key.ecs_logs
  to   = module.ecs.aws_kms_key.ecs_logs
}

moved {
  from = aws_kms_alias.ecs_logs
  to   = module.ecs.aws_kms_alias.ecs_logs
}

moved {
  from = aws_cloudwatch_log_group.ecs
  to   = module.ecs.aws_cloudwatch_log_group.ecs
}

moved {
  from = aws_iam_role.ecs_task_execution
  to   = module.ecs.aws_iam_role.ecs_task_execution
}

moved {
  from = aws_iam_role_policy.ecs_secrets
  to   = module.ecs.aws_iam_role_policy.ecs_secrets
}

moved {
  from = aws_iam_role_policy_attachment.ecs_task_execution
  to   = module.ecs.aws_iam_role_policy_attachment.ecs_task_execution
}

moved {
  from = aws_iam_role.ecs_task
  to   = module.ecs.aws_iam_role.ecs_task
}

moved {
  from = aws_iam_role_policy.ecs_exec_ssm
  to   = module.ecs.aws_iam_role_policy.ecs_exec_ssm
}

# ALB resources

moved {
  from = aws_lb.this
  to   = module.alb.aws_lb.this
}

moved {
  from = aws_lb_target_group.this
  to   = module.alb.aws_lb_target_group.this
}

moved {
  from = aws_lb_listener.this
  to   = module.alb.aws_lb_listener.this
}

# EKS resources
moved {
  from = aws_iam_role.eks_cluster
  to   = module.eks.aws_iam_role.eks_cluster
}

moved {
  from = aws_iam_role_policy_attachment.eks_cluster_policy
  to   = module.eks.aws_iam_role_policy_attachment.eks_cluster_policy
}

moved {
  from = aws_iam_role.eks_nodes
  to   = module.eks.aws_iam_role.eks_nodes
}

moved {
  from = aws_iam_role_policy_attachment.eks_worker_node
  to   = module.eks.aws_iam_role_policy_attachment.eks_worker_node
}

moved {
  from = aws_iam_role_policy_attachment.eks_cni
  to   = module.eks.aws_iam_role_policy_attachment.eks_cni
}

moved {
  from = aws_iam_role_policy_attachment.eks_ecr_read
  to   = module.eks.aws_iam_role_policy_attachment.eks_ecr_read
}

moved {
  from = aws_kms_key.eks_secrets
  to   = module.eks.aws_kms_key.eks_secrets
}

moved {
  from = aws_kms_alias.eks_secrets
  to   = module.eks.aws_kms_alias.eks_secrets
}

moved {
  from = aws_cloudwatch_log_group.eks
  to   = module.eks.aws_cloudwatch_log_group.eks
}

moved {
  from = aws_eks_cluster.this
  to   = module.eks.aws_eks_cluster.this
}

moved {
  from = aws_eks_node_group.this
  to   = module.eks.aws_eks_node_group.this
}