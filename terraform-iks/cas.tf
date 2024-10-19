resource "ibm_container_vpc_cluster" "cas_cluster" {
  name              = "cas-iks"
  vpc_id            = var.vpc_id
  flavor            = var.flavour
  kube_version      = var.kube_version
  worker_count      = var.worker_count
  resource_group_id = var.resource_group

  dynamic "zones" {
    for_each = var.zones
    content {
      subnet_id = zones.value["subnet_id"]
      name      = zones.value["name"]
    }
  }
  tags = ["cas-${var.tag_uuid}"]

}

resource "ibm_container_vpc_worker_pool" "cas_pool" {
  cluster          = ibm_container_vpc_cluster.cas_cluster.name
  worker_pool_name = "${ibm_container_vpc_cluster.cas_cluster.name}_vpc_pool"
  flavor           = var.flavour
  vpc_id           = ibm_container_vpc_cluster.cas_cluster.vpc_id
  worker_count     = var.worker_pool_count

  dynamic "zones" {
    for_each = var.zones
    content {
      subnet_id = zones.value["subnet_id"]
      name      = zones.value["name"]
    }
  }
}

data "ibm_container_cluster_config" "cas" {
  cluster_name_id = ibm_container_vpc_cluster.cas_cluster.id
  config_dir      = "${var.kube_config_path}/files/kubeconfig-iks-cas"
}
