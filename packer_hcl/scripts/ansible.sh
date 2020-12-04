#!/bin/bash -eux

# Install Ansible repository.
#sudo apt-get -y update && sudo apt-get -y upgrade
#sudo apt-get -y install software-properties-common
#sudo apt-add-repository ppa:ansible/ansible
sudo yum -y install rpm
#sudo rpm -i epel-release-latest-7.noarch.rpm
#sudo subscription-manager repos --enable rhel-7-server-ansible-2.9-rpms
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y update && sudo yum -y upgrade

# Install Ansible.
#sudo apt-get -y install ansible
sudo yum -y install ansible
