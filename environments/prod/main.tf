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

# 2. 보안 그룹

# (1) ALB Security Group
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
  public_subnets = module.vpc.public_subnet_ids

  security_group_ids = [module.sg_alb.security_group_id]
}

# 4. API Gateway 모듈
module "api_gateway" {
  source = "../../modules/api-gateway"
  alb_dns_name = module.alb.alb_dns_name
}

# (2) ECS Security Group (ALB에서의 접근만 허용)
module "sg_ecs" {
  source = "../../modules/security-groups"

  name   = "courm-sg-ecs-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 8080
      to_port         = 8080
      protocol        = "tcp"
      security_groups = [module.sg_alb.security_group_id] # 체이닝
    }
  ]
}

# (3) RDS Security Group (ECS에서의 접근만 허용)
module "sg_rds" {
  source = "../../modules/security-groups"

  name   = "courm-sg-rds-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [module.sg_ecs.security_group_id] # 체이닝
    }
  ]
}

# (4) Redis Security Group (ECS에서의 접근만 허용)
module "sg_redis" {
  source = "../../modules/security-groups"

  name   = "courm-sg-redis-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 6379
      to_port         = 6379
      protocol        = "tcp"
      security_groups = [module.sg_ecs.security_group_id] # 체이닝
    }
  ]
}

# 3. RDS
module "rds_order" {
  source = "../../modules/rds"

  identifier         = "courm-rds-order-${var.environment}"
  environment        = var.environment
  db_name            = "courm_order"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.data_subnet_ids
  security_group_ids = [module.sg_rds.security_group_id] # 변경된 SG ID 연결

  tags = { Service = "order-payment-user" }
}

module "rds_product" {
  source = "../../modules/rds"

  identifier         = "courm-rds-product-${var.environment}"
  environment        = var.environment
  db_name            = "courm_product"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.data_subnet_ids
  security_group_ids = [module.sg_rds.security_group_id] # 변경된 SG ID 연결

  # 기본값과 다른 설정만 오버라이드
  backup_retention_period = 3
  create_read_replica     = true

  tags = { Service = "product-review" }
}

# 4. ElastiCache (Redis)
module "elasticache_redis" {
  source = "../../modules/elasticache"

  cluster_id         = "courm-redis-${var.environment}"
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.data_subnet_ids
  security_group_ids = [module.sg_redis.security_group_id]
  # auth_token 자동 생성 (Secrets Manager 사용)

  tags = { Service = "product-cache-cart-lock" }
}

# 6. Jenkins EC2 보안그룹
module "sg_jenkins" {
  source = "../../modules/security-groups"

  name        = "courm-sg-jenkins-${var.environment}"
  vpc_id      = module.vpc.vpc_id

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
  ami_id = var.jenkins_ami_id
  instance_type = "t3.large"
  key_name = var.key_pair_name

  # 가용영역 A에 배치
  subnet_id = module.vpc.mgmt_subnet_ids[0]

  # Jenkins 전용 보안그룹 ID 연결
  security_group_ids = [module.sg_jenkins.security_group_id]
}

