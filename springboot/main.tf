terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
locals {
  nombre_workspace = terraform.workspace
  ruta_private_key = "~/Downloads/devops.pem"
  nombre_key = "devops"
  usuario_ssh = "ubuntu"
}


provider "aws" {
  region = var.aws_region
}


resource "aws_instance" "mi_app_spring" {
  count = terraform.workspace == "produccion" ? 2 : 1
  ami           = "ami-0ec10929233384c7f"
  instance_type = "t3.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.terraform-sg.security_group_id]
  associate_public_ip_address = true
  key_name = local.nombre_key
  tags = {
    Name = format("%s-%s",terraform.workspace,count.index)
  }
  provisioner "remote-exec" {
   inline = [
     "echo 'Esperando conexion SSH en ${self.public_ip}'",
   ]
   connection {
     type = "ssh"
     user = local.usuario_ssh
     private_key = file(local.ruta_private_key)
     host = self.public_ip
     timeout = "5m"
   }
   }
   provisioner "local-exec" {
     command = "ansible-playbook -i ${self.public_ip}, --private-key ${local.ruta_private_key} main.yml"
  }

}

resource "aws_cloudwatch_log_group" "grupo_log_ec2" {
  tags = {
    Perfil = "Default"
    Servicio    = "cloudwatch_spring"
  }
  lifecycle {
    create_before_destroy = true
  }

}
