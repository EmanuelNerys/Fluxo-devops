variable "pipeline_name" {
  type        = string
}

variable "repo_id" {
  description = "Seu usuario/nome-do-repositorio no GitHub (ex: EmanuelNerys/Fluxo-devops)"
  type        = string
}

variable "repo_branch" {
  type        = string
  default     = "master"
}

variable "ecr_repository_name" {
  type        = string
}

variable "ecs_cluster_name" {
  type        = string
}

variable "ecs_service_name" {
  type        = string
}