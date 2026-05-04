# outputs.tf

output "state_machine_arn" {
  description = "ARN del Step Function. Usalo para iniciar ejecuciones desde CLI."
  value       = aws_sfn_state_machine.banking-jessi.arn
}

output "s3_bucket_name" {
  description = "Bucket S3 donde se guardan las transacciones (approved/ y review/)."
  value       = aws_s3_bucket.transactions.bucket
}

output "validate_lambda" {
  description = "Nombre de la Lambda de validacion."
  value       = module.lambda_validate.function_name
}

output "risk_assess_lambda" {
  description = "Nombre de la Lambda de evaluacion de riesgo."
  value       = module.lambda_risk_assess.function_name
}

output "route_lambda" {
  description = "Nombre de la Lambda de ruteo a S3."
  value       = module.lambda_route.function_name
}
