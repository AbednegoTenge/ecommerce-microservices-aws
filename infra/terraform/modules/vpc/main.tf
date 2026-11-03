locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
    cidr_block           = var.vpc_cidr_block
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = "${local.name_prefix}-vpc"
    }
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id
    tags = {
        Name = "${local.name_prefix}-igw"
    }
}

resource "aws_nat_gateway" "this" {
    allocation_id = aws_eip.this.id
    subnet_id     = aws_subnet.public[0].id
    depends_on = [ aws_internet_gateway.this ]
    tags = {
        Name = "${local.name_prefix}-nat-gateway"
    }
}

resource "aws_eip" "this" {
    domain = "vpc"
    tags = {
        Name = "${local.name_prefix}-eip"
    }
}

resource "aws_route_table" "rt_public" {
    vpc_id = aws_vpc.this.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }
    tags = {
        Name = "${local.name_prefix}-rt-public"
    }
}

resource "aws_route_table" "rt_private" {
    vpc_id = aws_vpc.this.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.this.id
    }
    tags = {
        Name = "${local.name_prefix}-rt-private"
    }
}

resource "aws_route_table" "rt_data" {
    vpc_id = aws_vpc.this.id
    tags = {
        Name = "${local.name_prefix}-rt-data"
    }
}

resource "aws_route_table_association" "rta_public" {
    count = var.az_count
    subnet_id      = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rta_private" {
    count = var.az_count
    subnet_id      = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "rta_data" {
    count = var.az_count
    subnet_id      = aws_subnet.data[count.index].id
    route_table_id = aws_route_table.rt_data.id
}

resource "aws_subnet" "public" {
    count = var.az_count
    vpc_id = aws_vpc.this.id
    cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true
    tags = {
        Name = "${local.name_prefix}-public-subnet-${count.index}"
        "kubernetes.io/role/elb" = "1"
    }
}

resource "aws_subnet" "private" {
    count = var.az_count
    vpc_id = aws_vpc.this.id
    cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index + var.az_count)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
        Name = "${local.name_prefix}-private-subnet-${count.index}"
        "kubernetes.io/role/internal-elb" = "1"
    }
}

resource "aws_subnet" "data" {
    count = var.az_count
    vpc_id = aws_vpc.this.id
    cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index + (2 * var.az_count))
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
        Name = "${local.name_prefix}-data-subnet-${count.index}"
    }
}