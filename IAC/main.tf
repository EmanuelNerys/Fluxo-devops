# 1. Criação do Bucket S3 para o Estado
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "meu-terraform-state-policorp-998877"
  force_destroy = true 
}

# 2. CHAMA O MÓDULO DE REDE (Passando a sua VPC e Subnets)
module "minha_rede" {
  source     = "./modules/networking"
  sg_name    = "ecs-hello-world-sg"
  app_port   = 3000
  
  vpc_id     = "vpc-0d1add80f2e752f9a"
  subnet_ids = [
    "subnet-07c6561be5d68b16b", 
    "subnet-01e154689c68b933e"
  ]
}

# 3. CHAMA O MÓDULO DO ECR
module "meu_ecr" {
  source          = "./modules/ecr"
  repository_name = "hello-world-app"
}

# 4. CHAMA O MÓDULO DO ECS
module "meu_ecs" {
  source            = "./modules/ecs"
  cluster_name      = "hello-world-cluster"
  
  app_image         = "${module.meu_ecr.repository_url}:latest" 
  subnets           = module.minha_rede.subnet_ids
  security_group_id = module.minha_rede.security_group_id
}