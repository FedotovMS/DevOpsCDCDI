locals {
  # зіставляємо індекси 0..2 з cidr + az
  public_map  = { for idx, cidr in var.public_subnets  : idx => { cidr = cidr, az = var.availability_zones[idx] } }
  private_map = { for idx, cidr in var.private_subnets : idx => { cidr = cidr, az = var.availability_zones[idx] } }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = var.vpc_name }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.vpc_name}-igw" }
}

# Публічні підмережі (3)
resource "aws_subnet" "public" {
  for_each = local.public_map

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-${each.key}"
    Tier = "public"
  }
}

# Приватні підмережі (3)
resource "aws_subnet" "private" {
  for_each = local.private_map

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.vpc_name}-private-${each.key}"
    Tier = "private"
  }
}

# NAT: бюджетний варіант — один NAT у першій публічній підмережі
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.vpc_name}-nat-eip" }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id
  tags          = { Name = "${var.vpc_name}-nat" }
  depends_on    = [aws_internet_gateway.this]
}