module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = var.name

  instance_type = var.instance_type
  key_name      = var.key_name
  monitoring    = var.monitoring
  subnet_id     = "subnet-542ecb32"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

user_data = <<-EOF
              #!/bin/bash
              # 1. Install the EFS helper tool
              yum install -y amazon-efs-utils
              
              # 2. Create the mount point
              mkdir -p /var/www/html/shared
              
              # 3. Mount the EFS using its ID (Interpolated from Terraform)
              # The 'tls' option ensures data is encrypted in transit
              mount -t efs -o tls ${aws_efs_file_system.shared_storage.id}:/ /var/www/html/shared
              
              # 4. Make it persistent across reboots
              echo "${aws_efs_file_system.shared_storage.id}:/ /var/www/html/shared efs _netdev,tls 0 0" >> /etc/fstab
              EOF


  tags = {
    Terraform   = "true"
    Environment = var.env
  }
}

resource "aws_iam_role" "test_role" {
  name = "test-role-${var.env}"
 
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
 
  tags = {
    Terraform   = "true"
    Environment = var.env
  }
}

# 1. Create the EFS File System
resource "aws_efs_file_system" "shared_storage" {
  creation_token = "my-efs"
  encrypted      = true

  tags = {
    Name        = "MainStorage"
    Environment = var.env
  }
}

# 2. Create Mount Targets (Crucial: Create one for each subnet/AZ)
resource "aws_efs_mount_target" "alpha" {
  file_system_id  = aws_efs_file_system.shared_storage.id
  subnet_id       = var.subnet_id
  security_groups = [aws_security_group.efs_sg.id]
}




resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  # Allow HTTP for the browser test we did earlier
  ingress {
    from_port   = 2049
    to_port     = 2049
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


resource "aws_security_group" "ec2_sg" {
  name        = "ec2-web-sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  # Allow HTTP for the browser test we did earlier
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