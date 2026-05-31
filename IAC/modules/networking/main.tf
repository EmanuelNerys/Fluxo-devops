# Cria um Firewall (Security Group) apontando para a sua VPC específica
resource "aws_security_group" "app_sg" {
  name        = var.sg_name
  description = "Permite acesso na porta da aplicacao"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
