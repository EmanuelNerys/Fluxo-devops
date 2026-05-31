terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # COMENTADO TEMPORARIAMENTE PARA O BOOTSTRAP
  # backend "s3" {
  #   bucket       = "meu-terraform-state-policorp-998877"
  #   key          = "fluxo-devops/terraform.tfstate"
  #   region       = "us-east-1"
  #   encrypt      = true
  #   use_lockfile = true
  # }
}

provider "aws" {
  region = "us-east-1"
}