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