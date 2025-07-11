# Configure the Linode Provider
terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 2.0" # Use a compatible version
    }
  }
}

# Provider configuration
provider "linode" {
  token = var.linode_token
}

# Resource for the Linode Instance
resource "linode_instance" "mean_stack_vm" {
  label     = "mean-stack-server"
  region    = "ap-south" # Set to Singapore region
  type      = "g6-standard-1" # This corresponds to 2 CPU, 4GB RAM (refer to Linode pricing for types)
  image     = "linode/ubuntu22.04" # Ubuntu 22.04 LTS
  # root_pass = "" # Rely on SSH key authentication

  # Add SSH key for authentication
  authorized_keys = [
    var.ssh_public_key
  ]

  # Optional: Enable private IP for internal networking if needed
  private_ip = true

  # # Optional: User data for initial script execution
  # user_data = file("${path.module}/scripts/install_mean_stack.sh") # Example: path to a shell script

  tags = [
    "mean-stack",
    "web-server",
    "ubuntu"
  ]

# --- Cloud-Init Configuration ---
  user_data = <<-EOF
    #cloud-config
    # Cloud-init directives start with #cloud-config

    # Update and upgrade packages
    apt:
      update: true
      upgrade: true

    # Create a new user
    users:
      - name: {{ app_user }} # Using a variable from Terraform (see below)
        groups: sudo # Add to sudo group for administrative tasks
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL # Grant passwordless sudo for automation
        ssh_authorized_keys:
          - {{ ssh_public_key }} # Add the same public key for this user

    # Run arbitrary commands (e.g., install basic tools)
    runcmd:
      - echo "Cloud-init script started." >> /var/log/cloud-init-output.log
      - apt-get update -y
      - apt-get install -y git curl wget # Install common tools
      - echo "Basic tools installed." >> /var/log/cloud-init-output.log

    # Ensure the app directory exists and has correct permissions
    # This is often better handled by Ansible later, but shown for completeness
    # - mkdir -p /var/www/mean-app
    # - chown {{ app_user }}:{{ app_user }} /var/www/mean-app

    # You can add more complex shell scripts here
    # For instance, to install Node.js using NodeSource PPA, though Ansible is better for this.
    # - curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    # - apt-get install -y nodejs

    # You can also use write_files to create files
    # write_files:
    #   - path: /etc/my-custom-config.conf
    #     permissions: '0644'
    #     content: |
    #       MyCustomSetting=true
    #       AnotherSetting=value

  EOF
}


# Output the IP address of the newly created VM
# THIS IS THE CORRECT PLACEMENT FOR THE OUTPUT BLOCK
output "ip_address" {
  value       = linode_instance.mean_stack_vm.ip_address
  description = "The public IPv4 address of the Linode VM."
}

  
# Add these variables to your variables.tf if you haven't already

