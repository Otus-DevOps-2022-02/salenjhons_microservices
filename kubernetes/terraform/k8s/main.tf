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

resource "yandex_kubernetes_cluster" "reddit-cluster" {
    name            = "reddit-cluster"
    description     = "K8s cluster for reddit app"
    network_id      = "${yandex_vpc_network.k8s-network.id}"
    service_account_id = var.service_account_id
    node_service_account_id = var.service_account_id
    release_channel = "RAPID"

    master {
        version = "1.19"
        public_ip = true
        zonal {
          zone = var.zone
          subnet_id = "${yandex_vpc_subnet.k8s-subnet.id}"
        }
    }

}

resource "yandex_kubernetes_node_group" "reddit-node-group" {
  cluster_id  = "${yandex_kubernetes_cluster.reddit-cluster.id}"
  name        = "reddit-node-group"
  description = "node_group for reddit-cluster"
  version     = "1.19"

    instance_template {
    platform_id = "standard-v2"

    metadata    = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"

    }

    network_interface {
      nat                = true
      subnet_ids         = ["${yandex_vpc_subnet.k8s-subnet.id}"]
    }

    resources {
      memory = 8
      cores  = 4
      core_fraction = 100
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }
}



resource "yandex_vpc_network" "k8s-network" {
  name = "reddit-network"
}

resource "yandex_vpc_subnet" "k8s-subnet" {
  name           = "kube-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["10.244.0.0/16"]

}
