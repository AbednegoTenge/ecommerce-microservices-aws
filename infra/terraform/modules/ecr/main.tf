

resource "aws_ecr_repository" "this" {
  for_each  = toset(var.repository_names)
  name = "${var.project_name}-${each.value} "
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability_exclusion_filter {
    filter      = "latest*"
    filter_type = "WILDCARD"
  }

  image_tag_mutability_exclusion_filter {
    filter      = "dev-*"
    filter_type = "WILDCARD"
  }
  tags = {
    Name        = "${var.project_name}-${var.environment}-${each.value}"
    Environment = var.environment
  }
}


resource "aws_ecr_lifecycle_policy" "this" {
  for_each = toset(var.repository_names)
  repository = aws_ecr_repository.this[each.value].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 30 days"
        selection    = {
          tagStatus     = "untagged"
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 30
        }
        action       = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "keep last 10 images"
        selection    = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action       = {
          type = "expire"
        }
      }
    ]
  })
}