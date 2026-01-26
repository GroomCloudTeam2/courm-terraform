# terraform/environments/prod/backend.tf

terraform {
  backend "s3" {
    # 1단계에서 만든 버킷 이름
    bucket         = "courm-ecommerce-tf-state-storage"
    
    # 이 파일이 저장될 경로 (환경마다 다르게 해야 함! 예: prod/terraform.tfstate)
    key            = "prod/terraform.tfstate"
    
    region         = "ap-northeast-2"
    
    # 1단계에서 만든 DynamoDB 테이블 이름
    dynamodb_table = "courm-ecommerce-tf-locks"
    
    encrypt        = true
  }
}