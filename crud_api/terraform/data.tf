# data "aws_iam_policy_document" "ebs_csi_assume" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Federated"
#       identifiers = [module.eks.oidc_provider_arn]
#     }

#     actions = ["sts:AssumeRoleWithWebIdentity"]

#     condition {
#       test     = "StringEquals"
#       variable = "${module.eks.cluster_oidc_issuer_url}:sub"
#       values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
#     }
#   }
# }

# data "aws_iam_policy_document" "eks_irsa_sa" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]

#     principals {
#       type        = "Federated"
#       identifiers = [module.eks.oidc_provider_arn] # or your OIDC provider ARN
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:default:flask-api-sa"]
#     }
#   }
# }
# data "aws_iam_policy_document" "ebs_csi_driver_assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Federated"
#       identifiers = [module.eks.oidc_provider_arn]
#     }

#     actions = [
#       "sts:AssumeRoleWithWebIdentity",
#     ]

#     condition {
#       test     = "StringEquals"
#       variable = "${module.eks.oidc_provider}:aud"
#       values   = ["sts.amazonaws.com"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "${module.eks.oidc_provider}:sub"
#       values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
#     }

#   }
# }

# data "tls_certificate" "oidc" {
#   url = module.eks.cluster_oidc_issuer_url
# }

data "aws_iam_policy_document" "ebs_csi_driver" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}