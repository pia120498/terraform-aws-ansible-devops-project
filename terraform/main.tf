provider "aws" {
  region = "us-east-1"
}

data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "web_sg" {
  name = "terraform-web-sg"



  ingress {
    description = "HTTP"
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




resource "aws_iam_role" "ec2_ssm_role" {

  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ssm_policy" {

  role = aws_iam_role.ec2_ssm_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ec2_profile" {

  name = "ec2-ssm-profile"

  role = aws_iam_role.ec2_ssm_role.name
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