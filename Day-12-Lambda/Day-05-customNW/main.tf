# -------------------------
# Creation of VPC
# -------------------------
resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Dev-vpc"
  }
}

# -------------------------
# Public Subnet
# -------------------------
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.name.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Dev-public-subnet"
  }
}

# -------------------------
# Private Subnet
# -------------------------
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.name.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Dev-private-subnet"
  }
}

# -------------------------
# Internet Gateway
# -------------------------
resource "aws_internet_gateway" "name" {
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "Dev-IGW"
  }
}

# -------------------------
# Elastic IP for NAT Gateway
# -------------------------
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "Dev-NAT-EIP"
  }
}

# -------------------------
# NAT Gateway in Public Subnet
# -------------------------
resource "aws_nat_gateway" "name" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "Dev-NAT-GW"
  }
  depends_on = [aws_internet_gateway.name]
}

# -------------------------
# Public Route Table
# -------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.name.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.name.id
  }
  tags = {
    Name = "Dev-public-rt"
  }
}

# Public Subnet Association
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------
# Private Route Table
# -------------------------
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.name.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.name.id
  }
  tags = {
    Name = "Dev-private-rt"
  }
}

# Private Subnet Association
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# -------------------------
# Security Group
# -------------------------
resource "aws_security_group" "allow_tls" {
  name   = "allow_tls"
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "dev_sg"
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------
# EC2 Instance in Public Subnet
# -------------------------
resource "aws_instance" "public_instance" {
  ami                         = "ami-0d1891272a8f97fb4" # Add AMI ID
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.allow_tls.id]
  associate_public_ip_address = true
}

# -------------------------
# EC2 Instance in Private Subnet
# -------------------------
resource "aws_instance" "private_instance" {
  ami                         = "ami-0d1891272a8f97fb4" # Add AMI ID
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnet.id
  vpc_security_group_ids      = [aws_security_group.allow_tls.id]
  associate_public_ip_address = false
}
