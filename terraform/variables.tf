variable "oauth_token" {
  type      = string
  sensitive = true
}

variable "cloud_id" {
  type      = string
  sensitive = true
}

variable "folder_id" {
  type      = string
  sensitive = true
}

variable "zone_a" {
  type = string
}

variable "zone_b" {
  type = string
}

variable "zone_d" {
  type = string
}

variable "image_id" {
  type = string
}

variable "bastion_image_id" {
  type = string
}

variable "platform" {
  type = string
}

variable "ssh_host_user" {
  type = string
}

variable "ssh_bastion_user" {
  type = string
}

variable "ssh_folder" {
  type = string
}

variable "ssh_bastion" {
  type = string
}

variable "ssh_port" {
  type = string
}

variable "http_port" {
  type = string
}

variable "bastion_host_name" {
  type = string
}

variable "web1_host_name" {
  type = string
}

variable "web2_host_name" {
  type = string
}

variable "kibana_host_name" {
  type = string
}

variable "zabbix_host_name" {
  type = string
}

variable "elasticsearch_host_name" {
  type = string
}
