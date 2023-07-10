variable "resource_group_name" {
  type = string
  description = "Nombre del resource group"
  default = "rg-casopractico2TF"
}

variable "location_name" {
  type = string
  description = "Localización de la zona"
  default = "uksouth"
}

variable "network_name" {
  type = string
  description = "Nombre de la red"
  default = "vnet1"
}

variable "subnet_name" {
  type = string
  description = "Nombre de subred"
  default = "subnet1"
}

variable "ssh_user" {
  type        = string
  description = "Usuario para hacer ssh"
  default     = "azureuser"
}

variable "registry_name" {
  type = string
  description = "Nombre del registry de imágenes de contenedor"
  default = "jrng76"
}

variable "registry_sku" {
  type        = string
  description = "Tipo de SKU a utilizar por el registry. Opciones válidas: Basic, Standard, Premium."
  default     = "Basic"
}
