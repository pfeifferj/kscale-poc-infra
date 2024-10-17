variable "ibmcloud_api_key" {
  type = string
}

variable "flavour" {
  type = string
}

variable "kube_version" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "worker_count" {
  type = number
}

variable "worker_pool_count" {
  type = number
}

variable "resource_group" {
  type = string
}

variable "zones" {
  type = list(object({
    name      = string
    subnet_id = string
  }))
}

variable "tag_uuid" {
  description = "UUID used for tagging"
  type        = string
}

variable "kube_config_path" {
  type = string
}
