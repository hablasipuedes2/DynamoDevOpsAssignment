variable "region" {
  description = "AWS region"
  default     = "eu-north-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "crud-api-eks-cluster"
}

variable "desired_size" {
  default = 2
}

variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 3
}

variable "instance_types" {
  default = ["t3.micro"]
}
