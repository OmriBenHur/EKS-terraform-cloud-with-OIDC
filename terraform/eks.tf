#data obj to return eks cluster assume role policy to be used in the role creation
data "aws_iam_policy_document" "eks-cluster-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

#data obj to return eks node assume role policy to be used in the role creation
data "aws_iam_policy_document" "eks-node-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


# iam role for eks
resource "aws_iam_role" "eks-role" {
  name               = "eks"
  assume_role_policy = data.aws_iam_policy_document.eks-cluster-assume-role-policy.json
}

# iam role for eks nodes
resource "aws_iam_role" "eks-node-role" {
  name               = "${aws_eks_cluster.eks-cluster.name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks-node-assume-role-policy.json
}

# iam policy attachment for eks cluster role, permitting cluster actions
resource "aws_iam_policy_attachment" "eks-cluster-role-policy-attachment" {
  policy_arn = var.eks-cluster-role-policy-arn
  name       = "eks-cluster-role-policy-attachment"
  roles      = [aws_iam_role.eks-role.name]
}

# iam policy attachment for eks node role
resource "aws_iam_policy_attachment" "eks-node-role-policy-attachment" {
  for_each   = toset([for o in var.eks-node-role-policy-arn : o])
  policy_arn = each.value
  name       = "eks-node-role-policy-attachment"
  roles      = [aws_iam_role.eks-node-role.name]
}


# the eks cluster itself
resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.eks-role.arn


  vpc_config {
    subnet_ids = concat([for o in aws_subnet.private : o.id], [for j in aws_subnet.public : j.id])
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [aws_iam_policy_attachment.eks-cluster-role-policy-attachment]
}

resource "aws_eks_node_group" "private-node-group" {
  cluster_name   = aws_eks_cluster.eks-cluster.name
  node_role_arn  = aws_iam_role.eks-node-role.arn
  subnet_ids     = [for o in aws_subnet.public : o.id]
  capacity_type  = var.eks-private-node-capacity-type
  instance_types = [var.eks-private-node-instance-type]
  node_group_name = "${var.cluster-name}-private-node-group"

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }
}
