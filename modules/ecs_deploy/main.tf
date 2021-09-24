locals {
    capacity_provider       = format("%s-%s-%s-%s-%s", var.deployment_id,"ecs_capacity_provider", var.env, var.locationcode, "01")

}

# Provisioning Capacity provider with ASG with target capacity

resource "aws_ecs_capacity_provider" "provider" {
  name = local.capacity_provider
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg.arn

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 90
    }
  }
}

# ECS Cluster Creation 
#TODO Naming convention

resource "aws_ecs_cluster" "cluster" {
  name               = "base_cluster"
  capacity_providers = [aws_ecs_capacity_provider.provider.name]

  tags  = local.default_tags
}

# Defailt Task definition to launch a web app. 
resource "aws_ecs_task_definition" "task_definition" {
  family = "api-email-service"
  requires_compatibilities = [
      "EC2"
   ]
  cpu = 500
  memory = 500
  container_definitions = jsonencode([
    {
      name      = "container_api"
      image     = var.container_image_id
      cpu       = 300
      memory    = 300
      essential = true
      portMappings = [
        {
          containerPort = var.application_container_port
          hostPort      = var.application_container_port
        }
      ]
    }
  ])
}


resource "aws_ecs_service" "service" {
  name            = "api-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_definition.id
  desired_count   = 1
 
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "container_api"
    container_port   = var.application_container_port
  }
 
  launch_type = "EC2"
}