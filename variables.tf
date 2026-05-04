# variables.tf

variable "project_name" {
  type        = string
  description = "Prefijo para todos los recursos."
  default     = "banking-jessi"
}

variable "aws_region" {
  type        = string
  description = "Region AWS."
  default     = "us-east-1"
}
