output "id" {
  description = "The ID of the Management Group."
  value       = azurerm_management_group.this.id
}

output "name" {
  description = "The name of the Management Group."
  value       = azurerm_management_group.this.name
}