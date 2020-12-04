# Configure the Microsoft Azure Provider
provider "azurerm" {
  version = "~>2.0"
  features {}
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
}

//# creating persitance storage for terraform state files ** make sure these resources are present in Azure beforehand
//# remote state can also be created in the same resoruce group
//terraform {
//    backend "azurerm" {
//        resource_group_name  = "tf_rg_blobstore"
//        storage_account_name = "tf_mb_storage"
//        container_name       = "tfstate"
//        key                  = "terraform.tfstate"
//    }
//}

# Create a resource group if it doesn't exist
#resource "azurerm_resource_group" "tf_rg" {
#  name     = "mb-rg"
#  location = "UK South"
#  tags = {
#    environment = var.az_tag_env
#  }
#}

# Create virtual network
resource "azurerm_virtual_network" "tf_vn" {
  name                = "mb-vn"
  address_space       = ["10.0.0.0/16"]
  location            = var.az_location
  resource_group_name = var.az_rg
  tags = {
    environment = var.az_tag_env
  }
}

# Create subnet
resource "azurerm_subnet" "tf_sub" {
  name                 = "mb-sub"
  resource_group_name  = var.az_rg
  virtual_network_name = azurerm_virtual_network.tf_vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "tf_pub_ip" {
  name                = "mb-pub-ip"
  resource_group_name = var.az_rg
  location            = var.az_location
  allocation_method   = "Dynamic"

  tags = {
    environment = var.az_tag_env
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "tf_sg" {
    name                = "mb-sg"
    location            = var.az_location
    resource_group_name = var.az_rg

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = var.az_tag_env
    }
}

# Create network interface
resource "azurerm_network_interface" "tf_ni" {
  name = "mb-nic"
  location = var.az_location
  resource_group_name = var.az_rg

  ip_configuration {
    name = "mb-pvt-ip"
    subnet_id = azurerm_subnet.tf_sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.tf_pub_ip.id
  }
  tags = {
        environment = var.az_tag_env
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "tf-ni-sg-assoc" {
    network_interface_id      = azurerm_network_interface.tf_ni.id
    network_security_group_id = azurerm_network_security_group.tf_sg.id
}

# Generate random text for a unique storage account name
resource "random_id" "tf_randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = var.az_rg
    }
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "tf_storageaccount" {
    name                        = "diag${random_id.tf_randomId.hex}"
    resource_group_name         = var.az_rg
    location                    = var.az_location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = var.az_tag_env
    }
}

# Create (and display) an SSH key
resource "tls_private_key" "tf_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { value = tls_private_key.tf_ssh.private_key_pem }

resource "local_file" "azureuser_pem" {
  content  = tls_private_key.tf_ssh.private_key_pem
  filename = "azureuser.pem"
}

# Reference the VM image created by Packer
data "azurerm_image" "packer_image" {
  name = var.az_packer_image
  resource_group_name = var.az_rg
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "tf_vm1" {
  name                = "mb-rhel-vm1"
  resource_group_name = var.az_rg
  location            = var.az_location
  size                = "Standard_B1ls"
//  admin_username      = "adminuser"
  network_interface_ids = [azurerm_network_interface.tf_ni.id,]

//  admin_ssh_key {
//    username   = "adminuser"
//    public_key = file("~/.ssh/id_rsa.pub")
//  }

  os_disk {
    name                 = "mb-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = data.azurerm_image.packer_image.id

  # source_image_reference {
  # publisher = "Canonical"
  # offer     = "UbuntuServer"
  # #sku       = data.azurerm_image.packer_image.id #"16.04-LTS"
  # sku = id
  # version   = "latest"
  # #id = azurerm_image.packer_image.id
  # }

  computer_name  = "mb-rhel-vm1"
  admin_username = "azureuser"
  disable_password_authentication = true

    admin_ssh_key {
      username       = "azureuser"
      public_key     = tls_private_key.tf_ssh.public_key_openssh
    }

    boot_diagnostics {
      storage_account_uri = azurerm_storage_account.tf_storageaccount.primary_blob_endpoint
    }

    tags = {
      environment = var.az_tag_env
    }
}
