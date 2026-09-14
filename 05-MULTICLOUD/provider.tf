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
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.5.0"
    }
  }

  backend "s3" {
    bucket = "opskillup-c856b8eec35d"
    key    = "04-PROJECT-1/state.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

provider "azurerm" {
  features {
    
  }
}