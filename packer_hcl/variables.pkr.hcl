variable "az_client_id" {
  type =  string
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = true
}

variable "az_client_secret" {
  type =  string
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = true
}

variable "az_tenant_id" {
  type =  string
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = true
}

variable "az_subscription_id" {
  type =  string
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = true
}

variable "az_rg" {
  type =  string
  default = "rg-metro-digital-rig"
}

variable "az_location" {
  type =  string
  default = "South India"
}
