provider "aws" {
  region = "us-east-1"  # Update as necessary
}

resource "aws_instance" "c8" {
  ami           = "ami-01816d07b1128cd2d"  # Amazon Linux AMI ID
  instance_type = "t2.micro"
  key_name      = "ansible"
  tags = {
    Name = "c8.local"
  }
  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname c8.local
              EOF
}

resource "aws_instance" "u21" {
  ami           = "ami-0e2c8caa4b6378d8c"  # Ubuntu 21.04 AMI ID
  instance_type = "t2.micro"
  key_name      = "ansible"
  tags = {
    Name = "u21.local"
  }
  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname u21.local
              EOF
}

output "frontend" {
  value = aws_instance.c8.public_ip
}

output "backend" {
  value = aws_instance.u21.public_ip
}
