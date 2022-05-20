variable "cloud_id" {
  description = "Cloud"
}

variable "folder_id" {
  description = "Folder"
}

variable "zone" {
  description = "Zone"
  default     = "ru-central1=a"
}

variable "public_key_path" {
  description = "Path to public key"
}

variable "image_id" {
  description = "Disk image"
}

variable "subnet_id" {
  description = "Subnet"
}

variable "service_account_key_file" {
  description = "key.json"
}

variable "instance_count" {
  description = "Count of docker instances"
  default     = 1
}
