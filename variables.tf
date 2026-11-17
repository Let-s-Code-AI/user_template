variable "resource_group_name" {
  description = "Istniejąca RG kursanta (ustawiana przez TF_VAR_resource_group_name)."
  type        = string
}

variable "location" {
  description = "Region demo (ustawiany przez TF_VAR_location)."
  type        = string
  default     = "westeurope"
}

variable "log_retention_days" {
  description = "Po ilu dniach od modyfikacji usuwać bloby z kontenera logs."
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 1
    error_message = "log_retention_days musi wynosić co najmniej 1."
  }
}
