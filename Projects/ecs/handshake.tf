# Policy allowing Jenkins to launch and manage ECS tasks
resource "aws_iam_role_policy" "jenkins_ecs_handshake" {
  name = "jenkins-ecs-handshake-policy"
  role = aws_iam_role.jenkins_task_role.id # Using the Task Role

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:ListClusters",
          "ecs:DescribeClusters",
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "iam:PassRole",
        Resource = [
          aws_iam_role.ecs_execution_role.arn,
          aws_iam_role.jenkins_task_role.arn
        ]
      }
    ]
  })
}