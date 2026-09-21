terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}