resource "azurerm_management_group" "this" {
  name         = var.name
  display_name = var.display_name

  parent_management_group_id = var.parent_id
}