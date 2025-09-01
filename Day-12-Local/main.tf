locals {
  region ="eu-north-1"
  instance_type="t3.micro"
}

provider "aws" {
  region = local.region
}

resource "aws_instance" "name" {
  ami = "ami-0c4fc5dcabc9df21d"
  instance_type = local.instance_type
}