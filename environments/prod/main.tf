# courm-terraform/main.tf

# 1. VPC 모듈 호출
module "vpc" {
  source = "../../modules/vpc"

  environment    = var.environment
  vpc_cidr       = var.vpc_cidr
  azs            = var.azs
  public_subnets = var.public_subnets
  app_subnets    = var.app_subnets
  mq_subnets     = var.mq_subnets
  mgmt_subnets   = var.mgmt_subnets
  data_subnets   = var.data_subnets
}

# 2. 보안 그룹 모듈 호출
module "sg_alb" {
  source = "../../modules/security-groups"

  name   = "courm-sg-alb-${var.environment}"
  vpc_id = module.vpc.vpc_id
  description = "ALB Security Group"

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# 3. ALB 모듈
module "alb" {
  source = "../../modules/alb"

  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets

  security_group_ids = [module.sg_alb.security_group_id]
}

# 4. API Gateway 모듈
module "api_gateway" {
  source = "../../modules/api-gateway"
  alb_dns_name = module.alb.alb_dns_name
}
