<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.80.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | ../../modules/alb | n/a |
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | ../../modules/api-gateway | n/a |
| <a name="module_codedeploy_cart"></a> [codedeploy\_cart](#module\_codedeploy\_cart) | ../../modules/codedeploy | n/a |
| <a name="module_codedeploy_order"></a> [codedeploy\_order](#module\_codedeploy\_order) | ../../modules/codedeploy | n/a |
| <a name="module_codedeploy_payment"></a> [codedeploy\_payment](#module\_codedeploy\_payment) | ../../modules/codedeploy | n/a |
| <a name="module_codedeploy_product"></a> [codedeploy\_product](#module\_codedeploy\_product) | ../../modules/codedeploy | n/a |
| <a name="module_codedeploy_user"></a> [codedeploy\_user](#module\_codedeploy\_user) | ../../modules/codedeploy | n/a |
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | ../../modules/ecs-cluster | n/a |
| <a name="module_ecs_service_cart"></a> [ecs\_service\_cart](#module\_ecs\_service\_cart) | ../../modules/ecs-service | n/a |
| <a name="module_ecs_service_order"></a> [ecs\_service\_order](#module\_ecs\_service\_order) | ../../modules/ecs-service | n/a |
| <a name="module_ecs_service_payment"></a> [ecs\_service\_payment](#module\_ecs\_service\_payment) | ../../modules/ecs-service | n/a |
| <a name="module_ecs_service_product"></a> [ecs\_service\_product](#module\_ecs\_service\_product) | ../../modules/ecs-service | n/a |
| <a name="module_ecs_service_user"></a> [ecs\_service\_user](#module\_ecs\_service\_user) | ../../modules/ecs-service | n/a |
| <a name="module_elasticache_redis"></a> [elasticache\_redis](#module\_elasticache\_redis) | ../../modules/elasticache | n/a |
| <a name="module_internal_alb"></a> [internal\_alb](#module\_internal\_alb) | ../../modules/internal-alb | n/a |
| <a name="module_jenkins"></a> [jenkins](#module\_jenkins) | ../../modules/ec2-jenkins | n/a |
| <a name="module_kafka"></a> [kafka](#module\_kafka) | ../../modules/ec2-kafka | n/a |
| <a name="module_rds_order"></a> [rds\_order](#module\_rds\_order) | ../../modules/rds | n/a |
| <a name="module_rds_product"></a> [rds\_product](#module\_rds\_product) | ../../modules/rds | n/a |
| <a name="module_sg_alb"></a> [sg\_alb](#module\_sg\_alb) | ../../modules/security-groups | n/a |
| <a name="module_sg_ecs"></a> [sg\_ecs](#module\_sg\_ecs) | ../../modules/security-groups | n/a |
| <a name="module_sg_internal_alb"></a> [sg\_internal\_alb](#module\_sg\_internal\_alb) | ../../modules/security-groups | n/a |
| <a name="module_sg_jenkins"></a> [sg\_jenkins](#module\_sg\_jenkins) | ../../modules/security-groups | n/a |
| <a name="module_sg_kafka"></a> [sg\_kafka](#module\_sg\_kafka) | ../../modules/security-groups | n/a |
| <a name="module_sg_rds"></a> [sg\_rds](#module\_sg\_rds) | ../../modules/security-groups | n/a |
| <a name="module_sg_redis"></a> [sg\_redis](#module\_sg\_redis) | ../../modules/security-groups | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_codedeploy_app.goorm_ecommerce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_app) | resource |
| [aws_guardduty_detector.my_detector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) | resource |
| [aws_ecr_repository.cart](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository) | data source |
| [aws_ecr_repository.order](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository) | data source |
| [aws_ecr_repository.payment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository) | data source |
| [aws_ecr_repository.product](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository) | data source |
| [aws_ecr_repository.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_subnets"></a> [app\_subnets](#input\_app\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_azs"></a> [azs](#input\_azs) | n/a | `list(string)` | n/a | yes |
| <a name="input_data_subnets"></a> [data\_subnets](#input\_data\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | DB 마스터 비밀번호 | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | DB 마스터 사용자명 | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | 환경 이름 (예: prod) | `string` | n/a | yes |
| <a name="input_jenkins_ami_id"></a> [jenkins\_ami\_id](#input\_jenkins\_ami\_id) | --- Jenkins --- | `string` | n/a | yes |
| <a name="input_jenkins_instance_type"></a> [jenkins\_instance\_type](#input\_jenkins\_instance\_type) | n/a | `string` | n/a | yes |
| <a name="input_kafka_ami_id"></a> [kafka\_ami\_id](#input\_kafka\_ami\_id) | --- Kafka --- | `string` | n/a | yes |
| <a name="input_kafka_instance_type"></a> [kafka\_instance\_type](#input\_kafka\_instance\_type) | n/a | `string` | n/a | yes |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | n/a | `string` | n/a | yes |
| <a name="input_mgmt_subnets"></a> [mgmt\_subnets](#input\_mgmt\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_mq_subnets"></a> [mq\_subnets](#input\_mq\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | `"courm"` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS 리전 | `string` | `"ap-northeast-2"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | --- 네트워크 --- | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_url"></a> [api\_gateway\_url](#output\_api\_gateway\_url) | 최종 접속 URL |
| <a name="output_jenkins_url"></a> [jenkins\_url](#output\_jenkins\_url) | 젠킨스 접속 URL |
| <a name="output_rds_endpoints"></a> [rds\_endpoints](#output\_rds\_endpoints) | DB 접속 주소 |
| <a name="output_redis_endpoint"></a> [redis\_endpoint](#output\_redis\_endpoint) | Redis 엔드포인트 |
<!-- END_TF_DOCS -->