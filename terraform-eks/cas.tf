module "eks_al2" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "cas-eks"
  cluster_version = "1.29"

  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true
  eks_managed_node_groups = {
    cas = {
      ami_type      = "AL2_x86_64"
      instance_type = "m5.large"

      min_size = var.worker_pool_count
      max_size = var.worker_pool_count
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = var.worker_pool_count
    }
  }

  tags = {
    tag = "cas-${var.tag_uuid}"
  }
}
