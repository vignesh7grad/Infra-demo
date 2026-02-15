# 2. Create the EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "example"
  kubernetes_version = "1.33"

  endpoint_public_access = true

  control_plane_scaling_config = {
    tier = "tier-xl"
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_id

  eks_managed_node_groups = {
    general = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 2
    }
  }
  
  # Grants your current AWS user access to the cluster
  enable_cluster_creator_admin_permissions = true

   tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}