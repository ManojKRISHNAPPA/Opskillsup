terraform {
  backend "s3" {
    bucket = "op-skill-up-infra-backup"
    key = "op-skill-up-infra-backup/1-network/terraform.tfstate"
    region = "ap-northeast-1"
    dynamodb_table = "op-skill-up-infra-locks"
    encrypt = true
  }
}