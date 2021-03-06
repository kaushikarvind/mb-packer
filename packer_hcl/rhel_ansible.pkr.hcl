# This file was autogenerated by the BETA 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/from-1.5/variables#type-constraints for more info.
# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/from-1.5/blocks/source
source "azure-arm" "pkr_vm" {
  client_id                         = var.az_client_id
  client_secret                     = var.az_client_secret
  subscription_id                   = var.az_subscription_id
  tenant_id                         = var.az_tenant_id

  managed_image_name                = "mb-rhel-dec20"
  managed_image_resource_group_name = var.az_rg
  build_resource_group_name         = var.az_rg

  os_type                           = "Linux"
  image_offer                       = "RHEL"    #"UbuntuServer"
  image_publisher                   = "RedHat"  #"Canonical"
  image_sku                         = "7.5"     #"18.04-LTS"
  #location                          = var.az_location

  vm_size                           = "Standard_B1ls"  #"Standard_DS2_v2"
  ssh_username                      = "azureuser"

  azure_tags = {
    dept = "NA"
    task = "Packer Image Creation"
  }
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build
build {
  sources = ["source.azure-arm.pkr_vm"]

  provisioner "shell" {
    script = "scripts/ansible.sh"
  }
  provisioner "ansible-local" {
    playbook_file = "../ansible/site.yml"
    role_paths    = ["../ansible/roles/git", "../ansible/roles/nginx"]
    group_vars    = "../ansible/group_vars"
  }
  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }
  provisioner "shell" {
    inline = ["echo '************ DEPROVISION'", "sudo /usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"]
  }
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
