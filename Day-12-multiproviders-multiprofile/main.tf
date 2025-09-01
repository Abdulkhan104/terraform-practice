provider "aws" {
  region  = "eu-north-1"
  alias   = "abdul"
  profile = "abdul-profile"
}

provider "aws" {
  region  = "us-east-1"
  alias   = "dev"
  profile = "development-profile"
}

resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
  provider   = aws.dev
}

resource "aws_vpc" "abdul_vpc" {
  cidr_block = "10.1.0.0/16"
  provider   = aws.abdul
}

resource "aws_subnet" "dev_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  provider                = aws.dev
}

resource "aws_subnet" "abdul_subnet" {
  vpc_id                  = aws_vpc.abdul_vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  provider                = aws.abdul
}

resource "aws_internet_gateway" "dev_igw" {
  vpc_id   = aws_vpc.dev_vpc.id
  provider = aws.dev
}

resource "aws_internet_gateway" "abdul_igw" {
  vpc_id   = aws_vpc.abdul_vpc.id
  provider = aws.abdul
}

resource "aws_route_table" "dev_rt" {
  vpc_id   = aws_vpc.dev_vpc.id
  provider = aws.dev

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }
}

resource "aws_route_table_association" "dev_rta" {
  subnet_id      = aws_subnet.dev_subnet.id
  route_table_id = aws_route_table.dev_rt.id
  provider       = aws.dev
}

resource "aws_route_table" "abdul_rt" {
  vpc_id   = aws_vpc.abdul_vpc.id
  provider = aws.abdul

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.abdul_igw.id
  }
}

resource "aws_route_table_association" "abdul_rta" {
  subnet_id      = aws_subnet.abdul_subnet.id
  route_table_id = aws_route_table.abdul_rt.id
  provider       = aws.abdul
}

resource "aws_security_group" "dev_sg" {
  vpc_id   = aws_vpc.dev_vpc.id
  provider = aws.dev

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_security_group" "abdul_sg" {
  vpc_id   = aws_vpc.abdul_vpc.id
  provider = aws.abdul

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_s3_bucket" "dev_bucket" {
  bucket   = "mybucketttindev-2453"
  provider = aws.dev
}

resource "aws_s3_bucket" "abdul_bucket" {
  bucket   = "mybucketttinabdul-9083"
  provider = aws.abdul
}

resource "aws_instance" "dev_instance" {
  provider      = aws.dev
  ami           = "ami-00ca32bbc84273381"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.dev_subnet.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]

  tags = {
    Name = "Testing_Ec2"
  }
}
resource "aws_instance" "abdul_instance" {
  provider      = aws.abdul
  ami           = "ami-0c4fc5dcabc9df21d"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.abdul_subnet.id
  vpc_security_group_ids = [aws_security_group.abdul_sg.id]

  tags = {
    Name = "Production_Ec2"
  }
}
