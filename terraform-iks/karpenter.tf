resource "ibm_container_vpc_cluster" "karpenter_cluster" {
  name              = "karpenter"
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

  tags = {
    tag = "karpenter-${var.tag_uuid}"
  }
}
