resource "yandex_vpc_network" "k8s-network" {
  name = "k8s-network"
}

resource "yandex_vpc_subnet" "k8s-subnet" {
  name           = "k8s-subnet"
  zone           = var.zone_id
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_address" "srv-public-ip" {
  name = "srv-public-ip"
  
  external_ipv4_address {
    zone_id = var.zone_id
    # Параметр address должен быть полностью удален, а не оставлен пустым
  }

  lifecycle {
    prevent_destroy = true
  }
}