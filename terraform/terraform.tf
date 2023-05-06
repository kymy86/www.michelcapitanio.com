terraform {
  backend "s3" {
    bucket         = "terraform-20230506091927249500000001"
    key            = "michelcapitanio"
    region         = "eu-central-1"
    dynamodb_table = "michelcapitanio-terraform-state-locking"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.63.0"
    }
  }
}