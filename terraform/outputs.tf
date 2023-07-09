output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}

output "sg_id" {
  value = azurerm_network_security_group.sg.id
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "tls_private_key" {
  value = tls_private_key.claves_ssh.private_key_pem
  sensitive = true
}

