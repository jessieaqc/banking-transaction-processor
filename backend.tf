# backend.tf
# Configuracion del backend remoto. El bucket y la tabla DynamoDB
# fueron creados por el bootstrap (carpeta bootstrap/) UNA SOLA VEZ.
#
# IMPORTANTE: el alumno debe cambiar el valor de "bucket" por el que
# le devolvio el bootstrap. La tabla y region son fijas.

terraform {
  required_version = ">= 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  backend "s3" {
    bucket  = "banking-jessi-state-quintero"
    key     = "banking-jessi/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
