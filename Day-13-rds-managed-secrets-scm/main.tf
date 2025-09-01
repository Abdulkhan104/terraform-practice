provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "dev"
  }
}

# Subnet 1
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-1"
  }
}

# Subnet 2
resource "aws_subnet" "subnet-2" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-2"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "sub-grp" {
  name       = "mycutsubnet"
  subnet_ids = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

# RDS Instance
resource "aws_db_instance" "default" {
  allocated_storage       = 10
  identifier              = "book-rds"
  db_name                 = "mydb"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"

  manage_master_user_password = true
  username                    = "admin"

  db_subnet_group_name    = aws_db_subnet_group.sub-grp.id
  parameter_group_name    = "default.mysql8.0"

  backup_retention_period = 7
  backup_window           = "02:00-03:00"

  maintenance_window      = "sun:04:00-sun:05:00"
  deletion_protection     = false   # ✅ disable for now
  skip_final_snapshot     = true    # ✅ so you can destroy without snapshot

  depends_on = [aws_db_subnet_group.sub-grp]
}