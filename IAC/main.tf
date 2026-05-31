# 1. Criação do Bucket S3 para o Estado do Terraform
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "fluxo-devops-terraform-state"
  force_destroy = true 
}

# 2. CHAMA O MÓDULO DE REDE (Sua VPC e Subnets)
# CHAMA O MÓDULO DE REDE
module "minha_rede" {
  source     = "./modules/networking"
  sg_name    = "ecs-hello-world-sg"
  app_port   = 3000
  
  vpc_id     = "vpc-0d1add80f2e752f9a" 
  subnet_ids = [
    "subnet-0768b5c313829fa33", 
    "subnet-06e8d7eda0cb8323f"
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

# 5. CHAMA O MÓDULO DO CODEPIPELINE/CODEBUILD
module "meu_pipeline" {
  source              = "./modules/pipeline"
  pipeline_name       = "hello-world-pipeline"
  
  repo_id             = "EmanuelNerys/Fluxo-devops"
  repo_branch         = "main"
  
  ecr_repository_name = "hello-world-app"
  ecs_cluster_name    = module.meu_ecs.cluster_name
  ecs_service_name    = module.meu_ecs.service_name
} 