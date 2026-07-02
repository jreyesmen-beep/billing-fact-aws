variable "aws_region" {
  description = "Region de AWS"
  type        = string
  default     = "us-east-1"
}

variable "certificado_p12_path" {
  description = "Ruta local al archivo .p12"
  type        = string
}

variable "certificado_password" {
  description = "Password del certificado .p12"
  type        = string
  sensitive   = true  # Terraform no lo mostrará en logs
}

variable "ambiente" {
  description = "certificacion o produccion"
  type        = string
  default     = "cert10"
}
