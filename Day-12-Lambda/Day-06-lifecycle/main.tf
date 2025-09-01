resource "aws_instance" "name" {
  ami = "ami-0b83c7f5e2823d1f4"
  instance_type = "t3.micro"
  tags = {
    Name="dev"
  }

  lifecycle {
    prevent_destroy = true
    create_before_destroy = false
    ignore_changes = [ tags , ami , instance_type ]
  }
}

