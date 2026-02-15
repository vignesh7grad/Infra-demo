# 1. ECS Cluster
resource "aws_ecs_cluster" "jenkins_cluster" {
  name = "jenkins-cluster"
}


# 3. ECS Task Definition
resource "aws_ecs_task_definition" "jenkins_task" {
  family                   = "jenkins-controller"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.jenkins_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "jenkins"
      image     = "581199458150.dkr.ecr.us-east-1.amazonaws.com/demo-ecr-dev:latest"
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        { containerPort = 8080, hostPort = 8080 },
        { containerPort = 50000, hostPort = 50000 }
      ]

      # ADD THIS LOG CONFIGURATION
     logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.jenkins_logs.name
        "awslogs-region"        = "us-east-1" # Replace with your region
        "awslogs-stream-prefix" = "ecs"
       }
     }
      mountPoints = [
        {
          sourceVolume  = "jenkins-home"
          containerPath = "/home/jenkins_home"
          readOnly      = false
        }
      ]
    }
  ])

  volume {
    name = "jenkins-home"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.jenkins_home.id
      root_directory = "/"
    }
  }
}

# 4. ECS Service
resource "aws_ecs_service" "jenkins_service" {
  name            = "jenkins-service"
  cluster         = aws_ecs_cluster.jenkins_cluster.id
  task_definition = aws_ecs_task_definition.jenkins_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  enable_execute_command = true
  network_configuration {
    subnets          = ["subnet-3e5dbb61","subnet-542ecb32" ,"subnet-34816215"] # Update these
    security_groups  = [aws_security_group.jenkins_sg.id]
    assign_public_ip = true
  }
}

resource "aws_cloudwatch_log_group" "jenkins_logs" {
  name              = "/ecs/jenkins-controller"
  retention_in_days = 7
}
