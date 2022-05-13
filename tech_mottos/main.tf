terraform {
  cloud {
    organization = "kejadlen"

    workspaces {
      name = "bots"
    }
  }
}

provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::143867594019:role/terraform_cloud"
  }
}

variable "tech_mottos_secrets" {
  type = object({
    wordnik = object({
      api_key = string
    })
    twitter = object({
      api_key             = string
      api_secret          = string
      access_token        = string
      access_token_secret = string
    })
  })
  sensitive = true
  nullable  = false
}

data "aws_iam_policy" "lambda_basic_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "tech_mottos" {
  name = "tech_mottos"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [data.aws_iam_policy.lambda_basic_execution.arn]
}

resource "aws_secretsmanager_secret" "tech_mottos" {
  name = "tech_mottos"
}

resource "aws_secretsmanager_secret_policy" "tech_mottos" {
  secret_arn = aws_secretsmanager_secret.tech_mottos.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "secretsmanager:GetSecretValue"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.tech_mottos.arn
        }
        Resource = aws_secretsmanager_secret.tech_mottos.arn
      },
    ]
  })
}

resource "aws_secretsmanager_secret_version" "tech_mottos" {
  secret_id     = aws_secretsmanager_secret.tech_mottos.id
  secret_string = jsonencode(var.tech_mottos_secrets)
}

resource "null_resource" "package" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command     = "make package"
    working_dir = path.module
  }
}

data "archive_file" "tech_mottos" {
  type = "zip"

  source_dir  = "${path.module}/package"
  output_path = "${path.module}/package.zip"

  depends_on = [
    null_resource.package
  ]
}

resource "aws_lambda_function" "tech_mottos" {
  filename      = data.archive_file.tech_mottos.output_path
  function_name = "tech_mottos"
  role          = aws_iam_role.tech_mottos.arn
  handler       = "main.handler"

  source_code_hash = filebase64sha256(data.archive_file.tech_mottos.output_path)

  runtime = "python3.9"
  timeout = 10

  environment {
    variables = {
      SECRET_ID = aws_secretsmanager_secret.tech_mottos.id
    }
  }
}

resource "aws_cloudwatch_event_rule" "every_three_hours" {
  name                = "every-three-hours"
  schedule_expression = "rate(3 hours)"
}

resource "aws_cloudwatch_event_target" "tech_mottos" {
  rule = aws_cloudwatch_event_rule.every_three_hours.name
  arn  = aws_lambda_function.tech_mottos.arn
}

resource "aws_lambda_permission" "event_bridge" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tech_mottos.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_three_hours.arn
}
