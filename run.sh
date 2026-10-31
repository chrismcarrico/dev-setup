#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "Updating system and installing Ansible..."
sudo pacman -Syu --needed ansible git

echo "Installing required Ansible collections..."
ansible-galaxy collection install -r requirements.yml

echo "Running playbook..."
# ansible.cfg prompts for the sudo password (become_ask_pass)
# Extra arguments pass through, e.g. ./run.sh --tags dotfiles
ansible-playbook local.yml "$@"
