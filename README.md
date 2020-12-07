# packer-ansible-terraform

#Packer files in both json & hcl format and both are fit for use - choose as per your convenience

#packer.json file can be further improved by providing variables (rather than placing in the main file) - to be used as env variable or via a file from command line

#Update the ansible playbook based on the installations that are required on the packer image -currently it installs git, ngnix & growlerfriday program

#Do use relevant AZ principle & secret credentials to authenticate with Azure

### Pre-requisites

#Create a resoruce group in Azure, with the same name as it is declared in variables under packer_hcl or packer_json folder

#Create variables.auto.pkrvars.hcl under packer_hcl folder - it should declare the critical variables client id, client secret, tenant id & subscription id

#Create a resoruce group in Azure, with the same name as it is declared in variables under packer_hcl or packer_json folder

#Create terraform.tfvars file within the terraform folder - it should declare the critical variables client id, client secret, tenant id & subscription id
