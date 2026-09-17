data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "op-skill-up-infra-backup"
    key    = "op-skill-up-infra-backup/1-network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}