# bootstrap/variables.tf

variable "aws_region" {
  description = "Region de AWS donde se crea el bucket del state."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Nombre del bucket S3 para el state remoto. Debe ser globalmente unico."
  type        = string
  default     = "banking-jessi-state-quintero"
}
