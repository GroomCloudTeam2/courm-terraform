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

# 2. ALB 보안 그룹
module "sg_alb" {
  source = "../../modules/security-groups"

  name   = "courm-sg-alb-${var.environment}"
  vpc_id = module.vpc.vpc_id

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

# 6. Jenkins EC2 보안그룹
module "sg_jenkins" {
  source = "../../modules/security-groups"

  name        = "courm-sg-jenkins-${var.environment}"
  vpc_id      = module.vpc.vpc_id
  description = "Jenkins Security Group"

  ingress_rules = [
    {
      from_port   = 8080            # 젠킨스 웹 UI 포트
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 22              # SSH 접속 포트
      to_port     = 22
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

# 6. Jenkins EC2 모듈
module "jenkins" {
  source = "../../modules/ec2-jenkins"

  name     = "courm-jenkins-${var.environment}"
  ami_id = var.jenkins_ami_id      # variables.tf에 변수 추가 필요
  instance_type = "t3.medium"             # 젠킨스는 t3.small 이상 권장
  key_name = var.key_pair_name       # variables.tf에 변수 추가 필요

  # 가용영역 A에 배치하기
  subnet_id = module.vpc.mgmt_subnets[0]

  # Jenkins 전용 보안그룹 ID 연결
  security_group_ids = [module.sg_jenkins.security_group_id]
}

