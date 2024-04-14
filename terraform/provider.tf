terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

# https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs

provider "yandex" {
  token     = var.oauth_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}

#service_account_key_file = var.service_account_key_file
