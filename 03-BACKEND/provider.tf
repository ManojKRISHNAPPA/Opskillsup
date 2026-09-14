terraform {
  required_version = "~> 1.16.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.64.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }

  backend "s3" {
    bucket = "opskillup-c856b8eec35d"
    key    = "03/BACKEND/state.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}