provider "aws" {
  region = "eu-north-1"
}

variable "ec2" {
  type    = list(string)
  default = ["dev","prod"]
}

resource "aws_instance" "name" {
  ami           = "ami-0c4fc5dcabc9df21d"  
  instance_type = "t3.micro"
  count         = length(var.ec2)

  tags = {
    Name = var.ec2[count.index]
  }
}
