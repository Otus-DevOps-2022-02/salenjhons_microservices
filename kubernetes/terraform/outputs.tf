output "external_ip_address_kube_nondes" {
    value  = yandex_compute_instance.kube-node.*.network_interface.0.nat_ip_address
}
