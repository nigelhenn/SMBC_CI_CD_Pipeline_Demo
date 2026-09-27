terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

resource "aws_instance" "web" {
  count = var.enable_aws ? var.instance_count : 0
  ami   = var.ami_id

  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = var.security_groups

  tags = {
    Name        = "smbc-web-${count.index + 1}"
    Environment = var.environment
    Project     = "SMBC_CI_CD_Demo"
  }
}
