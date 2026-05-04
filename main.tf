# main.tf
# Banking Transaction Processor:
#   S3 (almacenamiento) + 3 Lambdas + Step Function con Choice

provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# S3: bucket donde para las transacciones procesadas
# -----------------------------------------------------------------------------

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "transactions" {
  bucket        = "${var.project_name}-transactions-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "transactions" {
  bucket                  = aws_s3_bucket.transactions.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# Lambdas: 3 funciones via modulo reutilizable
# -----------------------------------------------------------------------------

module "lambda_validate" {
  source        = "./modules/lambda_function"
  function_name = "${var.project_name}-validate"
  source_dir    = "${path.module}/lambdas/validate"
  role_arn      = aws_iam_role.lambda_role.arn
}

module "lambda_risk_assess" {
  source        = "./modules/lambda_function"
  function_name = "${var.project_name}-risk-assess"
  source_dir    = "${path.module}/lambdas/risk_assess"
  role_arn      = aws_iam_role.lambda_role.arn
}

module "lambda_route" {
  source        = "./modules/lambda_function"
  function_name = "${var.project_name}-route"
  source_dir    = "${path.module}/lambdas/route"
  role_arn      = aws_iam_role.lambda_role.arn
  environment_variables = {
    BUCKET_NAME = aws_s3_bucket.transactions.bucket
  }
}

# Log groups explicitos para que tofu destroy los limpie
resource "aws_cloudwatch_log_group" "validate_logs" {
  name              = "/aws/lambda/${module.lambda_validate.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "risk_assess_logs" {
  name              = "/aws/lambda/${module.lambda_risk_assess.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "route_logs" {
  name              = "/aws/lambda/${module.lambda_route.function_name}"
  retention_in_days = 7
}

# -----------------------------------------------------------------------------
# Step Function: orquesta las 3 Lambdas
# -----------------------------------------------------------------------------

resource "aws_sfn_state_machine" "banking-jessi" {
  name     = "${var.project_name}-state-machine"
  role_arn = aws_iam_role.sfn_role.arn

  definition = templatefile("${path.module}/step_function.asl.json", {
    validate_arn    = module.lambda_validate.function_arn
    risk_assess_arn = module.lambda_risk_assess.function_arn
    route_arn       = module.lambda_route.function_arn
  })

  tags = {
    Project = var.project_name
  }
}
