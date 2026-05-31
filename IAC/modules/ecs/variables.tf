variable "cluster_name" {
  description = "Nome do cluster ECS"
  type        = string
}

variable "app_image" {
  description = "URL da imagem no ECR"
  type        = string
}

variable "subnets" {
  description = "Lista de subnets para o ECS Service"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID do Security Group"
  type        = string
}