# resource "aws_instance" "name" {
#   ami = "ami-0c4fc5dcabc9df21d"
#   instance_type = "t3.micro"
# }
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"   # change to your AWS region
}

resource "aws_instance" "name" {
   ami = "ami-0c4fc5dcabc9df21d"
  instance_type = "t3.micro"
}
