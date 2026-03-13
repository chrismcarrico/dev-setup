#!/bin/bash
set -e

echo "Installing required Ansible collections..."
ansible-galaxy install -r requirements.yml

echo "Running playbook..."
# -K asks for the sudo password (become_password)
ansible-playbook local.yml -K
