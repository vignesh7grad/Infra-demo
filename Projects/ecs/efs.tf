# 2. EFS File System for Persistence
resource "aws_efs_file_system" "jenkins_home" {
  creation_token = "jenkins-home"
  tags = { Name = "JenkinsHome" }
}

resource "aws_efs_mount_target" "jenkins_mt" {
  count           = 2
  file_system_id  = aws_efs_file_system.jenkins_home.id
  subnet_id       = ["subnet-3e5dbb61","subnet-542ecb32" ,"subnet-34816215"][count.index] # Update these
  security_groups = [aws_security_group.jenkins_sg.id]
}

# 1. Security Group (The "Firewall")
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-access"
  description = "Allow Jenkins UI and EFS traffic"
  vpc_id      = "vpc-b50e3fcf" # Replace with your VPC ID

  # Jenkins Web UI
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In production, restrict this to your IP
  }

  # EFS Traffic (NFS)
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# 2. IAM Execution Role (Allows ECS to pull images/logs)
resource "aws_iam_role" "ecs_execution_role" {
  name = "jenkins-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_standard" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 3. IAM Task Role (Allows Jenkins to interact with AWS APIs)
resource "aws_iam_role" "jenkins_task_role" {
  name = "jenkins-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
    "ecs:ListClusters",
    "ecs:DescribeClusters",
    "ecs:ListTaskDefinitions",
    "ecs:DescribeTaskDefinition",
    "ssmmessages:CreateControlChannel",
    "ssmmessages:CreateDataChannel",
    "ssmmessages:OpenControlChannel",
    "ssmmessages:OpenDataChannel"
  ]

  resources = ["*"]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "jenkins-policy"
  description = "Jenkins policy"
  policy      = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.jenkins_task_role.name
  policy_arn = aws_iam_policy.policy.arn
}