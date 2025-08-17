module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.1.0"

  name    = var.cluster_name
  kubernetes_version = "1.30"

  endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      min_size     = 1
      max_size     = 3

      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.47.0-eksbuild.1"
  service_account_role_arn = module.eks.irsa_role_arn
}

resource "aws_iam_role_policy" "ebs_csi_irsa_policy" {
  name = "ebs-csi-irsa-policy"
  role = module.eks.irsa_role_name  # or irsa_role_arn if you prefer using ARN

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVolume",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:DeleteVolume",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeInstances",
          "ec2:ModifyVolume",
          "ec2:DescribeTags",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      }
    ]
  })
}

# TODO: Migrate to Kubernetes Manifest
# resource "kubernetes_storage_class" "ebs_sc" {
#   metadata {
#     name = "ebs-sc"
#   }

#   storage_provisioner          = "ebs.csi.aws.com"
#   reclaim_policy      = "Retain"

#   parameters = {
#     type = "gp3"
#   }
# }

resource "helm_release" "sealed_secrets" {
  name       = "sealed-secrets"
  namespace  = "kube-system"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  version    = "2.15.3" # check latest

  set {
    name  = "fullnameOverride"
    value = "sealed-secrets-controller"
  }
}

# Assume role policy for Kubernetes ServiceAccount
data "aws_iam_policy_document" "eks_irsa_sa" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn] # from your EKS module
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:flask-api-sa"]
    }
  }
}

# IAM role for ECR access
resource "aws_iam_role" "flask_api_role" {
  name               = "flask-api-role"
  assume_role_policy = data.aws_iam_policy_document.eks_irsa_sa.json
}

# IAM policy allowing ECR pull
resource "aws_iam_role_policy" "flask_api_ecr" {
  name = "flask-api-ecr-policy"
  role = aws_iam_role.flask_api_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}
