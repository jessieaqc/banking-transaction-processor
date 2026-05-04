# bootstrap/outputs.tf

output "state_bucket_name" {
  description = "Nombre del bucket. Copialo en banking-jessi/backend.tf -> bucket."
  value       = aws_s3_bucket.state.bucket
}

output "state_bucket_arn" {
  description = "ARN del bucket del state."
  value       = aws_s3_bucket.state.arn
}
