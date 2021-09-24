locals {
    default_tags = {
      createdBy   =      var.created_by
      app_module  =      var.app_module
    }
}

module "vpc-1" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-01"
  cidr = var.cidrange

  azs             = [var.az1, var.az2]
  private_subnets = [var.public-subnet-1-block, var.public-subnet-2-block]
  public_subnets  = [var.private-subnet-1-block, var.private-subnet-2-block]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = local.default_tags
}

output "vpc_id" {
  value = module.vpc-1.vpc_id
}

output "private_subnets" {
    value = module.vpc-1.private_subnets
}
