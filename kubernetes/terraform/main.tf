terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

data "yandex_compute_image" "image" {
  folder_id = "standard-images"
  family    = "ubuntu-1804-lts"
}

resource "yandex_compute_instance" "kube-node" {
    count          = var.count_of_nodes
    name           = "kube-node-${count.index}"

    platform_id    = "standard-v2"

    resources {
        cores  = 4
        memory = 4
    }

    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.image.id
            size     = 40
        }
    }


    metadata = {
        ssh-keys = "ubuntu:${file(var.public_key_path)}"
    }


    network_interface {
        subnet_id = yandex_vpc_subnet.kube-subnet.id
        nat       = true
    }
}


resource "yandex_vpc_network" "kube-network" {
  name = "gitlab-network"
}

resource "yandex_vpc_subnet" "kube-subnet" {
  name           = "kube-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.kube-network.id
  v4_cidr_blocks = ["10.244.0.0/16"]
}
