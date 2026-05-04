# iam.tf
# Rol IAM y permisos para la Lambda.

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

# Permisos basicos: CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permisos a S3
data "aws_iam_policy_document" "lambda_data_access" {
  statement {
    sid       = "S3WriteTransactions"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.transactions.arn}/*"]
  }
}

resource "aws_iam_policy" "lambda_data_access" {
  name   = "${var.project_name}-lambda-data-access"
  policy = data.aws_iam_policy_document.lambda_data_access.json
}

resource "aws_iam_role_policy_attachment" "lambda_data_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_data_access.arn
}

# Rol para step function

data "aws_iam_policy_document" "sfn_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sfn_role" {
  name               = "${var.project_name}-sfn-role"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume.json
}

data "aws_iam_policy_document" "sfn_invoke_lambdas" {
  statement {
    sid     = "InvokeLambdas"
    effect  = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [
      module.lambda_validate.function_arn,
      module.lambda_risk_assess.function_arn,
      module.lambda_route.function_arn,
    ]
  }
}

resource "aws_iam_policy" "sfn_invoke_lambdas" {
  name   = "${var.project_name}-sfn-invoke"
  policy = data.aws_iam_policy_document.sfn_invoke_lambdas.json
}

resource "aws_iam_role_policy_attachment" "sfn_invoke_lambdas" {
  role       = aws_iam_role.sfn_role.name
  policy_arn = aws_iam_policy.sfn_invoke_lambdas.arn
}