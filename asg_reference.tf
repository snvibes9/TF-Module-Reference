/* # create an auto scaling group for the ecs service
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 
  min_capacity       = 
  resource_id        = "service/${}/${}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = 
} */

provider "aws" {
  region = "us-east-1"
}

# Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/my-cluster/my-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Scale Out Policy
resource "aws_appautoscaling_policy" "scale_out" {
  name               = "ecs-scale-out"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 75.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_out_cooldown  = 60
    scale_in_cooldown   = 60
  }
}

# Scale In Policy
resource "aws_appautoscaling_policy" "scale_in" {
  name               = "ecs-scale-in"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 30.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_out_cooldown  = 60
    scale_in_cooldown   = 60
  }
}
