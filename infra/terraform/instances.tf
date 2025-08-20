resource "yandex_compute_instance" "k8s-master" {
  name        = "k8s-master"
  hostname = "k8s-master"
  platform_id = "standard-v3"
  zone        = var.zone_id
  service_account_id = data.yandex_iam_service_account.existing_sa.id
  #service_account_id = yandex_iam_service_account.k8s-sa.id

  resources {
    cores         = 2
    memory        = 4  # Увеличил с 2 GB
    core_fraction = 50 # Гарантированная доля vCPU
  }

  scheduling_policy {
    preemptible = true  # Прерываемая ВМ
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_22.id
      size     = 20    # Минимальный размер для Ubuntu
      type     = "network-hdd"  # Самый дешевый тип
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.k8s-subnet.id
    nat       = true
    ip_address = "192.168.10.10"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"  # Фиксированный пользователь ubuntu
  }
}

resource "yandex_compute_instance" "k8s-app" {
  name        = "k8s-app"
  hostname = "k8s-app"
  platform_id = "standard-v3"
  zone        = var.zone_id

  resources {
    cores         = 2
    memory        = 2  # Уменьшено до 2 GB
    core_fraction = 20 # Меньше гарантий для worker
  }

  scheduling_policy {
    preemptible = true  # Прерываемая ВМ
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_22.id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.k8s-subnet.id
    nat       = true
    ip_address = "192.168.10.11"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "srv" {
  name        = "srv"
  hostname = "srv"
  platform_id = "standard-v3"
  zone        = var.zone_id

  resources {
    cores         = 2
    memory        = 4  # Увеличил с 2 GB
    core_fraction = 50
  }

  scheduling_policy {
    preemptible = true  # Прерываемая ВМ
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_22.id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.k8s-subnet.id
    nat           = true
    nat_ip_address = yandex_vpc_address.srv-public-ip.external_ipv4_address[0].address
    ip_address    = "192.168.10.100"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}