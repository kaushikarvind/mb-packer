variable "subscription_id" {
    description = "Enter Subscription ID"
}

variable "client_id" {
    description = "Enter client ID"
}

variable "client_secret" {
    description = "Enter client secret"  
}

variable "tenant_id" {
    description = "Enter tenant ID"  
}

variable az_location {
    description = "Azure Region"
    default = "UK South"
}

variable az_rg {
    description = "Azure Resource Group"
    default = "mb-rg"
}

variable az_packer_image {
    description = "Azure Image created by Packer"
    default = "mb-rhel-dec20"
}

variable az_tag_env {
    description = "Environment Tag"
    default = "MB TF Demo"
}
