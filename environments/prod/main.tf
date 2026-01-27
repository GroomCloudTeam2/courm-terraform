# environments/prod/main.tf

# 1. VPC
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

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 8080
      to_port     = 8080
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

# 3-2. Internal ALB (서비스 간 통신용, VPC 내부 전용)
module "internal_alb" {
  source = "../../modules/internal-alb"

  name               = "courm-internal-alb"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.app_subnet_ids # 2개 AZ (ap-northeast-2a, 2c)
  security_group_ids = [module.sg_internal_alb.security_group_id]
}

# 4. API Gateway 모듈
module "api_gateway" {
  source = "../../modules/api-gateway"
  alb_dns_name = module.alb.alb_dns_name
}

# 5. ECR Data Sources (콘솔에서 생성된 레포지토리 정보 가져오기)
data "aws_ecr_repository" "user" { name = "goorm-user" }
data "aws_ecr_repository" "product" { name = "goorm-product" }
data "aws_ecr_repository" "order" { name = "goorm-order" }
data "aws_ecr_repository" "payment" { name = "goorm-payment" }
data "aws_ecr_repository" "cart" { name = "goorm-cart" }

locals {
  image_tag = "10-78435b3f"

  # 서비스 간 통신용 Internal ALB DNS (Path 기반 라우팅)
  internal_alb_dns = module.internal_alb.dns_name
  service_urls = [
    { name = "INTERNAL_ALB_URL",    value = "http://${module.internal_alb.dns_name}" },
    { name = "USER_SERVICE_URL",    value = "http://${module.internal_alb.dns_name}/users" },
    { name = "PRODUCT_SERVICE_URL", value = "http://${module.internal_alb.dns_name}/products" },
    { name = "ORDER_SERVICE_URL",   value = "http://${module.internal_alb.dns_name}/orders" },
    { name = "PAYMENT_SERVICE_URL", value = "http://${module.internal_alb.dns_name}/payments" },
    { name = "CART_SERVICE_URL",    value = "http://${module.internal_alb.dns_name}/carts" },
  ]
}

# (2-1) Internal ALB Security Group (ECS에서의 접근 허용, CIDR 기반 — 순환 참조 방지)
module "sg_internal_alb" {
  source = "../../modules/security-groups"

  name   = "courm-sg-internal-alb-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
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

# (2-2) ECS Security Group (외부 ALB + 내부 ALB에서의 접근 허용)
module "sg_ecs" {
  source = "../../modules/security-groups"

  name   = "courm-sg-ecs-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 8080
      to_port         = 8080
      protocol        = "tcp"
      security_groups = [module.sg_alb.security_group_id, module.sg_internal_alb.security_group_id]
    }
  ]

  egress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.sg_internal_alb.security_group_id]
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


# ==============================================================================
# 5. ECS Cluster
# ==============================================================================
module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  project     = var.project
  environment = var.environment
}

# ==============================================================================
# 6. ECS Services
# ==============================================================================

# (1) User Service
module "ecs_service_user" {
  source = "../../modules/ecs-service"

  project           = var.project
  environment       = var.environment
  service_name      = "user"
  cluster_id        = module.ecs_cluster.cluster_id
  execution_role_arn = module.ecs_cluster.execution_role_arn

  # Network
  subnet_ids        = module.vpc.app_subnet_ids
  security_group_id = module.sg_ecs.security_group_id
  
  # Load Balancer
  target_group_arn       = module.alb.target_group_arns["user"]
  green_target_group_arn = module.alb.target_group_arns_green["user"]
  internal_target_group_arn = module.internal_alb.target_group_arns["user"]

  # Container
  container_image   = "${data.aws_ecr_repository.user.repository_url}:${local.image_tag}" # TODO: 실제 ECR 주소로 변경 필요
  container_port    = 8080
  
  # Resource
  cpu               = 256
  memory            = 512
  desired_count     = 1
  health_check_grace_period = 600

  environment_variables = concat(
    [{ name = "SPRING_PROFILES_ACTIVE", value = var.environment }],
    local.service_urls
  )
}

# (2) Product Service
module "ecs_service_product" {
  source = "../../modules/ecs-service"

  project           = var.project
  environment       = var.environment
  service_name      = "product"
  cluster_id        = module.ecs_cluster.cluster_id
  execution_role_arn = module.ecs_cluster.execution_role_arn

  subnet_ids        = module.vpc.app_subnet_ids
  security_group_id = module.sg_ecs.security_group_id
  target_group_arn       = module.alb.target_group_arns["product"]
  green_target_group_arn = module.alb.target_group_arns_green["product"]
  internal_target_group_arn = module.internal_alb.target_group_arns["product"]

  container_image   = "${data.aws_ecr_repository.product.repository_url}:${local.image_tag}"
  container_port    = 8080
  desired_count     = 1
  health_check_grace_period = 600

  environment_variables = concat(
    [{ name = "SPRING_PROFILES_ACTIVE", value = var.environment }],
    local.service_urls
  )
}

# (3) Order Service
module "ecs_service_order" {
  source = "../../modules/ecs-service"

  project           = var.project
  environment       = var.environment
  service_name      = "order"
  cluster_id        = module.ecs_cluster.cluster_id
  execution_role_arn = module.ecs_cluster.execution_role_arn

  subnet_ids        = module.vpc.app_subnet_ids
  security_group_id = module.sg_ecs.security_group_id
  target_group_arn       = module.alb.target_group_arns["order"]
  green_target_group_arn = module.alb.target_group_arns_green["order"]
  internal_target_group_arn = module.internal_alb.target_group_arns["order"]

  container_image   = "${data.aws_ecr_repository.order.repository_url}:${local.image_tag}"
  container_port    = 8080
  desired_count     = 1
  health_check_grace_period = 600

  environment_variables = concat(
    [{ name = "SPRING_PROFILES_ACTIVE", value = var.environment }],
    local.service_urls
  )
}

# (4) Payment Service
module "ecs_service_payment" {
  source = "../../modules/ecs-service"

  project           = var.project
  environment       = var.environment
  service_name      = "payment"
  cluster_id        = module.ecs_cluster.cluster_id
  execution_role_arn = module.ecs_cluster.execution_role_arn

  subnet_ids        = module.vpc.app_subnet_ids
  security_group_id = module.sg_ecs.security_group_id
  target_group_arn       = module.alb.target_group_arns["payment"]
  green_target_group_arn = module.alb.target_group_arns_green["payment"]
  internal_target_group_arn = module.internal_alb.target_group_arns["payment"]

  container_image   = "${data.aws_ecr_repository.payment.repository_url}:${local.image_tag}"
  container_port    = 8080
  desired_count     = 1
  health_check_grace_period = 600

  environment_variables = concat(
    [{ name = "SPRING_PROFILES_ACTIVE", value = var.environment }],
    local.service_urls
  )
}

# (5) Cart Service
module "ecs_service_cart" {
  source = "../../modules/ecs-service"

  project           = var.project
  environment       = var.environment
  service_name      = "cart"
  cluster_id        = module.ecs_cluster.cluster_id
  execution_role_arn = module.ecs_cluster.execution_role_arn

  subnet_ids        = module.vpc.app_subnet_ids
  security_group_id = module.sg_ecs.security_group_id
  target_group_arn       = module.alb.target_group_arns["cart"]
  green_target_group_arn = module.alb.target_group_arns_green["cart"]
  internal_target_group_arn = module.internal_alb.target_group_arns["cart"]

  container_image   = "${data.aws_ecr_repository.cart.repository_url}:${local.image_tag}"
  container_port    = 8080
  desired_count     = 1
  health_check_grace_period = 600

  environment_variables = concat(
    [{ name = "SPRING_PROFILES_ACTIVE", value = var.environment }],
    local.service_urls
  )
}

# ==============================================================================
# 7. CodeDeploy (Blue/Green 배포)
# ==============================================================================

resource "aws_codedeploy_app" "goorm_ecommerce" {
  compute_platform = "ECS"
  name             = "goorm-ecommerce"
}

module "codedeploy_user" {
  source = "../../modules/codedeploy"

  project         = var.project
  app_name        = aws_codedeploy_app.goorm_ecommerce.name
  environment     = var.environment
  service_name    = "user"
  ecs_cluster_name = module.ecs_cluster.cluster_name
  ecs_service_name = module.ecs_service_user.service_name

  prod_listener_arns = [module.alb.alb_listener_arn]
  test_listener_arn  = module.alb.test_listener_arn

  blue_target_group_name  = module.alb.target_group_names["user"]
  green_target_group_name = module.alb.target_group_names_green["user"]

  codedeploy_role_arn = module.ecs_cluster.codedeploy_role_arn
}

module "codedeploy_product" {
  source = "../../modules/codedeploy"

  project         = var.project
  app_name        = aws_codedeploy_app.goorm_ecommerce.name
  environment     = var.environment
  service_name    = "product"
  ecs_cluster_name = module.ecs_cluster.cluster_name
  ecs_service_name = module.ecs_service_product.service_name

  prod_listener_arns = [module.alb.alb_listener_arn]
  test_listener_arn  = module.alb.test_listener_arn

  blue_target_group_name  = module.alb.target_group_names["product"]
  green_target_group_name = module.alb.target_group_names_green["product"]

  codedeploy_role_arn = module.ecs_cluster.codedeploy_role_arn
}

module "codedeploy_order" {
  source = "../../modules/codedeploy"

  project         = var.project
  app_name        = aws_codedeploy_app.goorm_ecommerce.name
  environment     = var.environment
  service_name    = "order"
  ecs_cluster_name = module.ecs_cluster.cluster_name
  ecs_service_name = module.ecs_service_order.service_name

  prod_listener_arns = [module.alb.alb_listener_arn]
  test_listener_arn  = module.alb.test_listener_arn

  blue_target_group_name  = module.alb.target_group_names["order"]
  green_target_group_name = module.alb.target_group_names_green["order"]

  codedeploy_role_arn = module.ecs_cluster.codedeploy_role_arn
}

module "codedeploy_payment" {
  source = "../../modules/codedeploy"

  project         = var.project
  app_name        = aws_codedeploy_app.goorm_ecommerce.name
  environment     = var.environment
  service_name    = "payment"
  ecs_cluster_name = module.ecs_cluster.cluster_name
  ecs_service_name = module.ecs_service_payment.service_name

  prod_listener_arns = [module.alb.alb_listener_arn]
  test_listener_arn  = module.alb.test_listener_arn

  blue_target_group_name  = module.alb.target_group_names["payment"]
  green_target_group_name = module.alb.target_group_names_green["payment"]

  codedeploy_role_arn = module.ecs_cluster.codedeploy_role_arn
}

module "codedeploy_cart" {
  source = "../../modules/codedeploy"

  project         = var.project
  app_name        = aws_codedeploy_app.goorm_ecommerce.name
  environment     = var.environment
  service_name    = "cart"
  ecs_cluster_name = module.ecs_cluster.cluster_name
  ecs_service_name = module.ecs_service_cart.service_name

  prod_listener_arns = [module.alb.alb_listener_arn]
  test_listener_arn  = module.alb.test_listener_arn

  blue_target_group_name  = module.alb.target_group_names["cart"]
  green_target_group_name = module.alb.target_group_names_green["cart"]

  codedeploy_role_arn = module.ecs_cluster.codedeploy_role_arn
}

