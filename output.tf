output "instance_id" {
  value = aws_instance.app_server.id
}

output "public_dns" {
  value = aws_instance.app_server.public_dns
}

output "shutdown_schedule" {
  value = "Instance will auto-stop after ${var.stop_time} minutes"
}