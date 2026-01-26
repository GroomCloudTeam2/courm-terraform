provider "aws"{
  region = "ap-northeast-2" # AWS 한국(서울) 리전 지정
  # profile = "aws_profile" # AWS CLI 프로파일
}

# 테라폼 설정 및 AWS Provider 설정
terraform {
  required_version = ">= 1.9.0" # 최소 테라폼 버전 설정

  required_providers {
    aws = {
      source = "hashicorp/aws" # AWS 프로바이더의 소스 지정
      version = ">= 5.80.0" # 5.80 버전 이상의 AWS 프로바이더 사용
    }
  }
}
