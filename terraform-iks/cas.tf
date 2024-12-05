resource "ibm_container_vpc_cluster" "cas_cluster" {
  name              = "cas-iks"
  vpc_id            = var.vpc_id
  flavor            = var.flavour
  kube_version      = var.kube_version
  worker_count      = 1 # 1 worker per zone
  resource_group_id = var.resource_group

  dynamic "zones" {
    for_each = var.zones
    content {
      subnet_id = zones.value["subnet_id"]
      name      = zones.value["name"]
    }
  }
  tags = ["cas-${var.tag_uuid}"]

  timeouts {
    create = "150m"
    delete = "30m"
  }

  disable_public_service_endpoint = false
}

data "ibm_container_cluster_config" "cas" {
  cluster_name_id = ibm_container_vpc_cluster.cas_cluster.id
  config_dir      = "${var.kube_config_path}/files/kubeconfig-iks-cas"
}
