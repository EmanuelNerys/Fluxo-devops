variable "sg_name" {
  description = "Nome do Security Group"
  type        = string
}

variable "app_port" {
  description = "Porta de acesso da aplicacao"
  type        = number
  default     = 3000
}

variable "vpc_id" {
  description = "ID da VPC existente"
  type        = string
}

variable "subnet_ids" {
  description = "Lista com os IDs das subnets existentes"
  type        = list(string)
}