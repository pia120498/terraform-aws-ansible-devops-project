provider "aws" {
  region = "us-east-1"
}

data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}



resource "aws_instance" "web_server" {

  ami           = data.aws_ssm_parameter.amazon_linux.value
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  user_data = <<-EOF
#!/bin/bash

dnf update -y

dnf install -y httpd

systemctl start httpd
systemctl enable httpd

echo "<h1>Hello from Terraform</h1>" > /var/www/html/index.html

EOF

  tags = {
    Name = "terraform-web-server"
  }
}