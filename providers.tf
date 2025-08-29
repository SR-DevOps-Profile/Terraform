terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.9.0"
    }
  }
}

provider "aws" {
  # Configuration options
  access_key = ""
  secret_key = ""
  region = "us-east-2"
}
