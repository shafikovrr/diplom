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

variable "image_id" {
  type = string
}

variable "platform" {
  type = string
}

#variable "service_account_key_file" {
#  description = "Service account key file"
#  type        = string
#  default     = "/home/adrin/.ssh/authorized_key.json"
#}
