locals {
    alb_security_group_name = format("%s-%s-%s-%s-%s", var.deployment_id, "alb-sg", var.env, var.locationcode, "01")
    alb_name                = format("%s-%s-%s-%s-%s", var.deployment_id, "alb", var.env, var.locationcode, "01")
    target_group_name       = format("%s-%s-%s-%s-%s", var.deployment_id,"tg", var.env, var.locationcode, "01")
    default_tags = {
      createdBy   =      var.created_by
      app_module  =      var.app_module
    }
}


# SG for load balancer which allows only http traffic within VPC

resource "aws_security_group" "lb" {
  name   = local.alb_security_group_name
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.default_tags
}

# Internal ALB Deploying in Private subnets
resource "aws_lb" "alb" {
  name               = local.alb_name
  load_balancer_type = "application"
  internal           = true
  security_groups    = [aws_security_group.lb.id]
  subnets            = [var.private_subnets[0],var.private_subnets[1] ]

  tags = local.default_tags
}

# Target group based on App's container port
# Need to make this health check path as configurable


resource "aws_lb_target_group" "tg" {
  name     = local.target_group_name
  port     = var.application_container_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/api/emails/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
  tags = local.default_tags

}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
  tags =  local.default_tags
}


output "tg_arn" {
  value = aws_lb_target_group.tg.arn
}

output "alb_listener_arn" {
  value = aws_lb_listener.listener.arn
}