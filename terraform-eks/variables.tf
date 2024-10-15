variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "tag_uuid" {
  description = "UUID used for tagging"
  type        = string
}


variable "worker_count" {
  type = number
}

variable "worker_pool_count" {
  type = number
}

variable "flavour" {
  type = string
}

variable "kube_version" {
  type = string
}