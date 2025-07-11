variable "linode_token" {
  description = "Your Linode API Token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Your SSH public key (e.g., ~/.ssh/id_rsa.pub content)"
  type        = string
  sensitive   = false
}

variable "app_user" {
  description = "The username for the application."
  type        = string
  default     = "meanappuser" # Or make it a variable you pass from GHA
}

variable "ssh_public_key" {
  description = "The SSH public key to add to the instance."
  type        = string
  sensitive   = true # Mark as sensitive
}