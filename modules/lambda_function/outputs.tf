# modules/lambda_function/outputs.tf

output "function_arn" {
  description = "ARN de la Lambda desplegada."
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Nombre de la Lambda desplegada."
  value       = aws_lambda_function.this.function_name
}
