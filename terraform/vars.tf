
# vpc CIDR range, this can be configured, subnets are created automatically
# from this CIDR range
variable "vpc_cidr_def" {
  description = "VPC cidr"
  default     = "10.0.0.0/16"
}

# data obj to return a list of available AZ's in the configured region
data "aws_availability_zones" "available_zones" {
  state = "available"
}

variable "vpc_name" {
  description = "VPC name"
  default     = "web-app"
}

variable "subnet_amount" {
  description = "subnet duplicate amount"
  default     = 2
}

variable "eks-cluster-role-policy-arn" {
  description = "arn for the policy to be attached to the eks cluster role"
  default     = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

variable "eks-node-role-policy-arn" {
  description = "arn for the policy to be attached to the eks node role"
  type        = list(any)
  default = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
             "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
             "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
            ]
}


variable "cluster-name" {
  description = "name for the eks cluster"
  default     = "app-cluster"
}

variable "eks-private-node-capacity-type" {
  default = "ON_DEMAND"
}
variable "eks-private-node-instance-type" {
  default = "t2.micro"
}

