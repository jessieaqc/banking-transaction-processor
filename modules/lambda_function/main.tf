# modules/lambda_function/main.tf
# Modulo reutilizable: empaqueta, sube y despliega una Lambda function.
# Se instancia tres veces desde main.tf (validate, risk_assess, route).

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/../../.build/${var.function_name}.zip"
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  role             = var.role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 30

  environment {
    variables = var.environment_variables
  }

  tags = {
    Project = "banking-jessi"
  }
}
