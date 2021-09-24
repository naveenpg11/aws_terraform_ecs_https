locals {

api_gatewayname = format("%s-%s-%s-%s-%s",var.deployment_id, "api-gw",var.env, var.locationcode, "01")
security-group-name = format("%s-%s-%s-%s-%s",var.deployment_id, "apigw-sg",var.env, var.locationcode, "01")

default_tags ={
  createdBy = var.created_by
  app_module = var.app_module
}
}


resource "aws_apigatewayv2_api" "api" {
  name          = local.api_gatewayname
  protocol_type = "HTTP"
}

# SG to allow internet traffic for vpc link

resource "aws_security_group" "vpc_link" {
  name   = local.security-group-name
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = local.default_tags
}

# VPC Link for our vpc and deploying in private subnet
resource "aws_apigatewayv2_vpc_link" "link" {
  name               = "vpc-link"
  security_group_ids = [aws_security_group.vpc_link.id]
  subnet_ids         = [var.private_subnets[0], var.private_subnets[1]]
}

resource "aws_apigatewayv2_integration" "api" {
  api_id           = aws_apigatewayv2_api.api.id
  description      = "APIGatewayV2 load balancer Integration"
  integration_type = "HTTP_PROXY"
  integration_uri  = var.alb_listener_arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      =  aws_apigatewayv2_vpc_link.link.id
  }

resource "aws_apigatewayv2_route" "api" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "ANY /"

  target = "integrations/${aws_apigatewayv2_integration.api.id}"
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "$default"

  target = "integrations/${aws_apigatewayv2_integration.api.id}"
}


resource "aws_apigatewayv2_stage" "api" {
  api_id = aws_apigatewayv2_api.api.id
  name   = "$default"
  auto_deploy = true
}


output "https_endpoint"{
    value = aws_apigatewayv2_api.api.api_endpoint
}

