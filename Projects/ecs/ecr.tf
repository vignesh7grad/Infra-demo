# 1. The Immutable ECR Repository
resource "aws_ecr_repository" "demo_repo" {
  name                 = "demo-ecr-${var.env}"
  
  # THIS MAKES IT IMMUTABLE
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    # Scans for vulnerabilities on every push (Best Practice)
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS" # Uses AWS managed key by default
  }

  tags = {
    Terraform   = "true"
    Environment = var.env
  }
}

# 2. Lifecycle Policy (FinOps: Cleanup old images to save money)
resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.demo_repo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only the last 30 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 30
      }
      action = {
        type = "expire"
      }
    }]
  })
}