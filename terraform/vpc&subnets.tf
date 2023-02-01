# vpc
resource "aws_vpc" "web_app_vpc" {
  cidr_block           = var.vpc_cidr_def
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc_name
  }
}


# creating 2 public subnets
resource "aws_subnet" "public" {
  count                   = var.subnet_amount
  vpc_id                  = aws_vpc.web_app_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.web_app_vpc.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name                                            = "${var.vpc_name}-public-subnet-${count.index + 1}"
    "Kubernetes.io / role / internal-elb"           = count.index
    "kubernetes.io / cluster / ${var.cluster-name}" = "owned"

  }
}
# creating 2 private subnets
resource "aws_subnet" "private" {
  count             = var.subnet_amount
  vpc_id            = aws_vpc.web_app_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.web_app_vpc.cidr_block, 8, 2 + var.subnet_amount + count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  tags = {
    Name                                            = "${var.vpc_name}-private-subnet-${count.index + 1}"
    "Kubernetes.io / role / internal-elb"           = 2 + count.index
    "kubernetes.io / cluster / ${var.cluster-name}" = "owned"
  }
}
