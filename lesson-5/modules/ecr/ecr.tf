data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "this" {
  name                 = var.ecr_name
  image_tag_mutability = var.immutable_tags ? "IMMUTABLE" : "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256" # можна KMS: kms_key = "...", encryption_type = "KMS"
  }

  tags = {
    Name    = var.ecr_name
    Managed = "terraform"
  }
}

# Проста Lifecycle-політика для економії: чистити непозначені (untagged) образи
resource "aws_ecr_lifecycle_policy" "cleanup" {
  count      = var.expire_untagged_after_days > 0 ? 1 : 0
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after ${var.expire_untagged_after_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.expire_untagged_after_days
        }
        action = { type = "expire" }
      }
    ]
  })
}

# Resource-based policy: дозволяємо root у поточному акаунті push/pull
data "aws_iam_policy_document" "repo_policy" {
  statement {
    sid = "AllowAccountRootPushPull"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:ListImages"
    ]
  }
}

resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = data.aws_iam_policy_document.repo_policy.json
}