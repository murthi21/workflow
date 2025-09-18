output "control_plane_ip" {
  value = aws_instance.k8s_cluster.public_ip
}

output "worker1_ip" {
  value = aws_instance.k8s_worker1.public_ip
}

output "worker2_ip" {
  value = aws_instance.k8s_worker2.public_ip
}

