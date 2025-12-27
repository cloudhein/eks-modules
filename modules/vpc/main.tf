resource "random_string" "random" {
  length  = 4
  special = false
}

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_range
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                                        = "${var.cluster_name}-vpc-${random_string.random.result}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

##### create public subnet 

resource "aws_subnet" "public_subnet" {

  count = length(var.public_subnets_cidr)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.cluster_name}-public-subnet-${count.index +1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}


##### create internet gateway for public subnet

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name                                        = "${var.cluster_name}-igw"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

##### create route table for public subnet

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name                                        = "${var.cluster_name}-public-rt"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/kind"                        = "public"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  count = length(var.public_subnets_cidr)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

##### create private subnet

resource "aws_subnet" "private_subnet" {

  count = length(var.private_subnets_cidr)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnets_cidr[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

   # ✅ CHANGE: Use merge() to combine default tags with the new variable
  tags = merge(
    {
      Name                                        = "${var.cluster_name}-private-subnet-${count.index + 1}"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    },
    var.private_subnet_tags # <--- Injects the Karpenter tags passed from root
  )
}

##### create one nat gateway for all private subnets

resource "aws_eip" "nat_eip" {
  #count  = length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name                                        = "${var.cluster_name}-nat-eip"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name                                        = "${var.cluster_name}-nat"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

##### create route table for private subnet

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name                                        = "${var.cluster_name}-private-rt"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/kind"                        = "private"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  count = length(var.private_subnets_cidr)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
