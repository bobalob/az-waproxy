variable "resource_group_location" {
  default     = "uksouth"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  default     = "rg-waproxy"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "virtual_machine_name" {
  default     = "waproxy"
  description = "Name of the VM"
}

variable "dns_prefix" {
  default     = "superwaproxy"
  description = "Unique DNS prefix for the public IP"
}

variable "os_disk_type" {
  default     = "StandardSSD_LRS"
  description = "Disk Type"
}

variable "machine_sku" {
  default     = "Standard_B1s"
  description = "VM Type"
}

variable "build_script" {
  default     = "install-waproxy.sh"
  description = "Script to install/config WhatsApp Proxy"
}

variable "username" {
  description = "local admin username"
}

variable "ssh_public_key" {
  description = "SSH public key for admin access"
}

variable "management_range" {
  description = "Source IP address / CIDR Range"
}
