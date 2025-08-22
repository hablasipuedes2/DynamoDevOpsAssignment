variable "region" {
  description = "AWS region"
  default     = "eu-north-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "crud-api-eks-cluster"
}

variable "instance_types" {
  default = ["t3.medium"]
}
