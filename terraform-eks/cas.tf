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

      min_size = 1
      max_size = 10
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = var.worker_pool_count
    }
  }

  tags = {
    tag = "cas-${var.tag_uuid}"
  }
}

# IAM role for cluster autoscaler
resource "aws_iam_role" "cluster_autoscaler" {
  name = "cas-eks-cluster-autoscaler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks_al2.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${module.eks_al2.oidc_provider}:sub" = "system:serviceaccount:cas:aws-cluster-autoscaler"
            "${module.eks_al2.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# IAM policy for cluster autoscaler
resource "aws_iam_role_policy" "cluster_autoscaler" {
  name = "cas-eks-cluster-autoscaler"
  role = aws_iam_role.cluster_autoscaler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# Output the IAM role ARN for use in Helm chart
output "cluster_autoscaler_role_arn" {
  description = "ARN of the IAM role for cluster autoscaler"
  value       = aws_iam_role.cluster_autoscaler.arn
}
