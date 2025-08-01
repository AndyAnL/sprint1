output "srv_public_ip" {
  value = yandex_compute_instance.srv.network_interface.0.nat_ip_address
}

output "k8s_master_private_ip" {
  value = yandex_compute_instance.k8s-master.network_interface.0.ip_address
}

output "k8s_worker_private_ip" {
  value = yandex_compute_instance.k8s-app.network_interface.0.ip_address
}