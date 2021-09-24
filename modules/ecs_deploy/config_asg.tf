locals {
  ecs_lc_security_group_name = format("%s-%s-%s-%s-%s", var.deployment_id, "ecs-asg-sg", var.env, var.locationcode, "01")
  launch_config_name = format("%s-%s-%s-%s-%s", var.deployment_id, "ecs-launch", var.env, var.locationcode, "01")
  ecs_asg_name = format("%s-%s-%s-%s-%s", var.deployment_id, "ecs-asg", var.env, var.locationcode, "01")
  default_tags = {
      createdBy   =      var.created_by
      app_module  =      var.app_module
    }
}



resource "aws_security_group" "ecs_lc" {
  name   = local.ecs_lc_security_group_name
  vpc_id = var.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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

#############

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon", "self"]
}

resource "aws_iam_role" "ecs-instance-role" {
  name = "ecs-instance-role-test-web"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = aws_iam_role.ecs-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_service_role" {
  role = aws_iam_role.ecs-instance-role.name
}

resource "aws_launch_configuration" "lc" {
  name          = local.launch_config_name
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  lifecycle {
    create_before_destroy = true
  }
  iam_instance_profile        = aws_iam_instance_profile.ecs_service_role.name
  security_groups             = [aws_security_group.ecs_lc.id]
  associate_public_ip_address = true
  user_data                   = <<EOF
#! /bin/bash
sudo apt-get update
sudo echo "ECS_CLUSTER=base_cluster" >> /etc/ecs/ecs.config
EOF
}


##################ASG



resource "aws_autoscaling_group" "asg" {
  name                      = local.ecs_asg_name
  launch_configuration      = aws_launch_configuration.lc.name
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = [var.private_subnets[0], var.private_subnets[1]]

}

