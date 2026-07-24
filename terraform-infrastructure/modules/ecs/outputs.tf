output "cluster_id" {
    description = "ECS cluster ID"
    value       = aws_ecs_cluster.this.id
}

output "cluster_arn" {
    description = "ECS cluster ARN."
    value       = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "ECS task definition ARN."
  value       = aws_ecs_task_definition.this.arn
}