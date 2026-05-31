# Busca o ID da sua conta AWS e a Região dinamicamente
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# 1. Cria um Bucket S3 apenas para os artefatos temporários do Pipeline
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket        = "${var.pipeline_name}-artifacts-998877"
  force_destroy = true
}

# 2. PERMISSÕES (IAM Roles) para o CodeBuild e CodePipeline
resource "aws_iam_role" "pipeline_role" {
  name = "${var.pipeline_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = ["codebuild.amazonaws.com", "codepipeline.amazonaws.com"] } }]
  })
}

resource "aws_iam_role_policy" "pipeline_policy" {
  name = "${var.pipeline_name}-policy"
  role = aws_iam_role.pipeline_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["s3:*", "ecr:*", "ecs:*", "iam:PassRole", "codebuild:*", "codestar-connections:*"], Resource = "*" }
    ]
  })
}

# 3. CRIAÇÃO DO AWS CODEBUILD (O Operário que faz o Docker Build)
resource "aws_codebuild_project" "build" {
  name          = "${var.pipeline_name}-build"
  service_role  = aws_iam_role.pipeline_role.arn

  artifacts { type = "CODEPIPELINE" }

 environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true # OBRIGATÓRIO PARA RODAR DOCKER

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }
    
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr_repository_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yaml" # Seu arquivo na raiz
  }
}

# 4. CONEXÃO COM O GITHUB (Gera um link que você precisará aprovar no painel da AWS uma única vez)
resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}

# 5. CRIAÇÃO DO AWS CODEPIPELINE (O Maestro)
resource "aws_codepipeline" "pipeline" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  # ETAPA 1: SOURCE (Puxa o código do GitHub)
  stage {
    name = "Source"
    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.repo_id
        BranchName       = var.repo_branch
      }
    }
  }

  # ETAPA 2: BUILD (Chama o CodeBuild para rodar o Docker)
  stage {
    name = "Build"
    action {
      name             = "Build_Docker"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = { project_name = aws_codebuild_project.build.name }
    }
  }

  # ETAPA 3: DEPLOY (Atualiza os containers do ECS Fargate)
  stage {
    name = "Deploy"
    action {
      name            = "Deploy_To_ECS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}