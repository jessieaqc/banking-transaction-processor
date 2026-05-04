# modules/lambda_function/variables.tf

variable "function_name" {
  description = "Nombre de la Lambda function."
  type        = string
}

variable "source_dir" {
  description = "Ruta al directorio que contiene lambda_function.py."
  type        = string
}

variable "role_arn" {
  description = "ARN del rol IAM que ejecuta la Lambda."
  type        = string
}

variable "environment_variables" {
  description = "Variables de entorno para la Lambda."
  type        = map(string)
  default     = {}
}
