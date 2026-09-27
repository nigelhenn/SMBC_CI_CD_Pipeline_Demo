variable "region" {
  default = "eu-west-1"
}

variable "enable_aws" {
  description = "Whether to create AWS resources. Set to false for credential-free validation and plans."
  type        = bool
  default     = false
}

variable "instance_count" {
  default = 8
}

variable "ami_id" {
  default = "ami-033a3fad07a25c231"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  default = "terraform"
}

variable "security_groups" {
  type    = list(string)
  default = ["launch-wizard-1"]
}

variable "environment" {
  description = "Environment name (dev/test/prod)"
  type        = string
  default     = "dev"
}
