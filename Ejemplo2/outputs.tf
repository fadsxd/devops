output "ip_addr_instance" {
  #value = aws_instance.mi_servidor.private_ip
  value = { for servicio, i in aws_instance.mi_servidor : servicio => i.private_ip }

}
