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
  kubernetes_version = "1.33"

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

data "aws_iam_policy_document" "ebs_csi_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${module.eks.cluster_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  name = "AmazonEKS_EBS_CSI_DriverRole"

  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}

# resource "aws_eks_addon" "ebs_csi" {
#   cluster_name             = module.eks.cluster_name
#   addon_name               = "aws-ebs-csi-driver"
#   service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
# }

# # IAM role for ECR access
# resource "aws_iam_role" "flask_api_role" {
#   name               = "flask-api-role"
#   assume_role_policy = data.aws_iam_policy_document.eks_irsa_sa.json
# }

# # IAM policy allowing ECR pull
# resource "aws_iam_role_policy" "flask_api_ecr" {
#   name = "flask-api-ecr-policy"
#   role = aws_iam_role.flask_api_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ecr:GetAuthorizationToken",
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:BatchGetImage"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }
