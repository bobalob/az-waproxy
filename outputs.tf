output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.waproxy_vm.public_ip_address
}

output "username" {
  value = var.username
}

output "fqdn" {
  value = azurerm_public_ip.waproxy_public_ip.fqdn
}

output "ssh_string" {
  value = "${var.username}@${azurerm_public_ip.waproxy_public_ip.fqdn}"
}

#output "tls_private_key" {
#  value     = tls_private_key.example_ssh.private_key_pem
#  sensitive = true
#}