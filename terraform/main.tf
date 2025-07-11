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
  # --- CORRECT Cloud-Init Configuration using the 'metadata' argument ---
  metadata {
    user_data = <<-EOF
      #cloud-config

      # Update and upgrade packages
      apt:
        update: true
        upgrade: true

      # Create a new user
      users:
        - name: {{ app_user }}
          groups: sudo
          shell: /bin/bash
          sudo: ALL=(ALL) NOPASSWD:ALL
          ssh_authorized_keys:
            - {{ ssh_public_key }}

      runcmd:
        - echo "Cloud-init script started." >> /var/log/cloud-init-output.log
        - apt-get install -y git curl wget

    EOF
    }

  # Optional: Enable private IP for internal networking if needed
  private_ip = true

  # # Optional: User data for initial script execution
  # user_data = file("${path.module}/scripts/install_mean_stack.sh") # Example: path to a shell script

  tags = [
    "mean-stack",
    "web-server",
    "ubuntu"
  ]
}


# Output the IP address of the newly created VM
# THIS IS THE CORRECT PLACEMENT FOR THE OUTPUT BLOCK
output "ip_address" {
  value       = linode_instance.mean_stack_vm.ip_address
  description = "The public IPv4 address of the Linode VM."
}

  
# Add these variables to your variables.tf if you haven't already

