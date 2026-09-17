module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.project
  kubernetes_version = var.kubernetes_version

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  # Optional
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.network.outputs.private_subnet_ids
  control_plane_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    default = {
      name           = "${var.project}-ng"
      instance_types = ["t3.medium"]
      ami_type       = "AL2023_x86_64_STANDARD"
      min_size       = 3
      max_size       = 5
      desired_size   = 3

      subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

      use_custom_launch_template = false

      remote_access = {
        ec2_ssh_key               = var.ssh_key_name
        source_security_group_ids = var.ssh_source_security_group_ids
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
