provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kustomization" {
    kubeconfig_raw         = yamlencode(local.kubeconfig)
    context                = local.kubeconfig_context
}

locals {
  kubeconfig_context = "_terraform-kustomization-${module.eks.cluster_name}_"

  kubeconfig = {
    apiVersion = "v1"
    clusters = [
      {
        name = local.kubeconfig_context
        cluster = {
          certificate-authority-data = module.eks.cluster_certificate_authority_data
          server                     = module.eks.cluster_endpoint
        }
      }
    ]
    users = [
      {
        name = local.kubeconfig_context
        user = {
          token = data.aws_eks_cluster_auth.this.token
        }
      }
    ]
    contexts = [
      {
        name = local.kubeconfig_context
        context = {
          cluster = local.kubeconfig_context
          user    = local.kubeconfig_context
        }
      }
    ]
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  name   = var.name
  region = var.region

  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  route53_zone_arns = [for hostedzone in var.r53_hosted_zones : "arn:aws:route53:::hostedzone/${hostedzone}"]

  tags = merge(var.tags, {
    Blueprint  = local.name
    GithubRepo = "github.com/awslabs/data-on-eks"
  })
}

#------------------------------------------------------------------
# EKS Cluster
#------------------------------------------------------------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name                   = local.name
  cluster_version                = var.eks_cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    node_group_one = {
      name        = "node-group-one"
      description = "EKS managed node group node-group-one"

      min_size     = 1
      max_size     = 9
      desired_size = 3

      instance_types = ["m5.xlarge"]

      ebs_optimized = true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 100
            volume_type = "gp3"
          }
        }
      }

      labels = {
        WorkerType    = "ON_DEMAND"
        # NodeGroupType = "core"
      }

      tags = {
        Name                     = "node-group-one",
        # "karpenter.sh/discovery" = local.name
      }
    }
  }

  tags = local.tags
}