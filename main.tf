terraform {
  required_providers {
    aws = {
      version = "~> 3.7"
    }
  }
}

provider "aws" {
  region = var.region
}

# Network modules create VPC, IGW, NACL, RouteTables, 2 Private Subnets, 2 private subnets and a NAT Gateway
module "networks" {
  source                     = "./modules/networks"
  cidrange                   = var.cidrange
  public-subnet-1-block      = var.public-subnet-1-block
  public-subnet-2-block      = var.public-subnet-2-block
  private-subnet-1-block      = var.private-subnet-1-block
  private-subnet-2-block      = var.private-subnet-2-block
  az1                        = var.az1
  az2                        = var.az2
  env                        = var.env
  locationcode               = lookup(var.locationcode, var.region)
  deployment_id              = var.deployment_id
  created_by                 = var.created_by
}


# load_balancer creates alb, tg, sg and a listener
module "load_balancer" {
  source                     = "./modules/load_balancer"
  vpc_id                     = module.networks.vpc_id
  vpc_cidr                   = var.cidrange
  private_subnets            = module.networks.private_subnets
  env                        = var.env
  locationcode               = lookup(var.locationcode, var.region)
  deployment_id              = var.deployment_id
  created_by                 = var.created_by
  application_container_port = var.application_container_port
}

# ecs_service creates task definition, ecs, service, capacity provider, launchConfig and Autoscaling group
module "ecs_service" {
  source       = "./modules/ecs_deploy"
  vpc_id                     = module.networks.vpc_id
  vpc_cidr                   = var.cidrange
  private_subnets            = module.networks.private_subnets
  application_container_port = var.application_container_port
  target_group_arn           = module.load_balancer.tg_arn
  container_image_id         = var.container_image_id

  env                        = var.env
  locationcode               = lookup(var.locationcode, var.region)
  deployment_id              = var.deployment_id
  created_by                 = var.created_by


  depends_on = [module.networks,module.load_balancer]
  
}

# expose_api_https_private creates HTTP API and its dependant component using vpc link

module "expose_api_https_private" {
  source = "./modules/gateway_https_private"
  vpc_id                     = module.networks.vpc_id
  private_subnets            = module.networks.private_subnets
  alb_listener_arn            = module.load_balancer.alb_listener_arn

  env                        = var.env
  locationcode               = lookup(var.locationcode, var.region)
  created_by                 = var.created_by
  deployment_id              = var.deployment_id

  depends_on = [module.networks, module.load_balancer]
}


output "https_endpoint" {
  value = module.expose_api_https_private.https_endpoint
}