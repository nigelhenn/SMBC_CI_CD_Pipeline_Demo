provider "aws" {
  region = var.region
}

resource "aws_instance" "web" {
  # Set enable_aws=false for validation/plan runs without AWS credentials
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
