variable cloud_id {
  description = "Cloud"
}
variable folder_id {
  description = "Folder"
}
variable zone {
  description = "Zone"
  default     = "ru-central1-b"
}
variable public_key_path {
  default = "~/.ssh/appuser.pub"
}

variable subnet_id {
  description = "Subnet"
}

variable count_of_nodes {
  description = "count of yc-nodes"
  default = 2
}

variable service_account_key_file {}


variable service_account_id {
  default = "aje5b54s7d8mkehs9bvl"
  description = "service account_id"
}
