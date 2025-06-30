locals {
  name_prefix = "${var.organization}-${var.project_name}-${var.environment}"

  # Calculate subnet CIDRs if not provided
  calculated_azs = length(var.availability_zones) > 0 ? var.availability_zones : [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]

  # Auto-calculate subnet CIDRs based on VPC CIDR
  vpc_cidr_prefix = split("/", var.vpc_cidr)[1]
  subnet_bits     = 8 - (tonumber(local.vpc_cidr_prefix) - 16) # /24 subnets for /16 VPC

  calculated_public_cidrs = length(var.public_subnet_cidrs) > 0 ? var.public_subnet_cidrs : [
    for i, az in local.calculated_azs : cidrsubnet(var.vpc_cidr, local.subnet_bits, i)
  ]

  calculated_private_cidrs = length(var.private_subnet_cidrs) > 0 ? var.private_subnet_cidrs : [
    for i, az in local.calculated_azs : cidrsubnet(var.vpc_cidr, local.subnet_bits, i + 10)
  ]

  calculated_database_cidrs = length(var.database_subnet_cidrs) > 0 ? var.database_subnet_cidrs : [
    for i, az in local.calculated_azs : cidrsubnet(var.vpc_cidr, local.subnet_bits, i + 20)
  ]
}

# ==============================================================================
# VPC
# ==============================================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

# ==============================================================================
# Internet Gateway
# ==============================================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# ==============================================================================
# Public Subnets
# ==============================================================================

resource "aws_subnet" "public" {
  count = length(local.calculated_azs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.calculated_public_cidrs[count.index]
  availability_zone       = local.calculated_azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-public-${count.index + 1}"
    Type = "public"
    Tier = "public"
  })
}

# ==============================================================================
# Private Subnets
# ==============================================================================

resource "aws_subnet" "private" {
  count = length(local.calculated_azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.calculated_private_cidrs[count.index]
  availability_zone = local.calculated_azs[count.index]

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-private-${count.index + 1}"
    Type = "private"
    Tier = "private"
  })
}

# ==============================================================================
# Database Subnets
# ==============================================================================

resource "aws_subnet" "database" {
  count = length(local.calculated_azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.calculated_database_cidrs[count.index]
  availability_zone = local.calculated_azs[count.index]

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-database-${count.index + 1}"
    Type = "database"
    Tier = "database"
  })
}

# Database subnet group for RDS
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-db-subnet-group"
  })
}

# ==============================================================================
# Elastic IPs for NAT Gateways
# ==============================================================================

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(local.calculated_azs)) : 0

  domain = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-eip-nat-${count.index + 1}"
  })
}

# ==============================================================================
# NAT Gateways
# ==============================================================================

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(local.calculated_azs)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.main]

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-nat-gateway-${count.index + 1}"
  })
}

# ==============================================================================
# Route Tables
# ==============================================================================

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-public-rt"
    Type = "public"
  })
}

# Private route tables
resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(local.calculated_azs)) : length(local.calculated_azs)

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
    }
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-private-rt-${count.index + 1}"
    Type = "private"
  })
}

# Database route tables
resource "aws_route_table" "database" {
  count = length(local.calculated_azs)

  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-database-rt-${count.index + 1}"
    Type = "database"
  })
}

# ==============================================================================
# Route Table Associations
# ==============================================================================

# Public subnet associations
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private subnet associations
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
}

# Database subnet associations
resource "aws_route_table_association" "database" {
  count = length(aws_subnet.database)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[count.index].id
}

# ==============================================================================
# Security Groups
# ==============================================================================

# Default security group for the VPC
resource "aws_security_group" "default" {
  name_prefix = "${local.name_prefix}-default-"
  vpc_id      = aws_vpc.main.id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-default-sg"
    Type = "default"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Web application security group
resource "aws_security_group" "web" {
  name_prefix = "${local.name_prefix}-web-"
  vpc_id      = aws_vpc.main.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-web-sg"
    Type = "web"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Database security group
resource "aws_security_group" "database" {
  name_prefix = "${local.name_prefix}-database-"
  vpc_id      = aws_vpc.main.id

  # MySQL/Aurora
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  # PostgreSQL
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-database-sg"
    Type = "database"
  })

  lifecycle {
    create_before_destroy = true
  }
}