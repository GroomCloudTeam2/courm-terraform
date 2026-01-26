# courm-terraform/main.tf

# 1. VPC 모듈 호출 (엔진 장착)
module "vpc" {
  source = "../../modules/vpc"

  # 변수 전달 (terraform.tfvars에서 받은 값을 모듈로 넘김)
  environment    = var.environment
  vpc_cidr       = var.vpc_cidr
  azs            = var.azs
  public_subnets = var.public_subnets
  app_subnets    = var.app_subnets
  mq_subnets     = var.mq_subnets
  mgmt_subnets   = var.mgmt_subnets
  data_subnets   = var.data_subnets
}

# 2. 보안 그룹 모듈 호출 (문짝 장착 - 테스트용으로 ALB 하나만 먼저)
module "sg_alb" {
  source = "../../modules/security-groups"

  name   = "courm-sg-alb-${var.environment}"
  vpc_id = module.vpc.vpc_id  # [핵심] 방금 만든 VPC 모듈의 ID를 가져와서 꽂음!

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
