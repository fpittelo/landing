# DEV Subscription Association
resource "azurerm_management_group_subscription_association" "dev" {
  management_group_id = module.mg_dev.id
  subscription_id     = var.subscription_dev_id
}

# QA Subscription Association
resource "azurerm_management_group_subscription_association" "qa" {
  management_group_id = module.mg_qa.id
  subscription_id     = var.subscription_qa_id
}

# MAIN Subscription Association
resource "azurerm_management_group_subscription_association" "main" {
  management_group_id = module.mg_main.id
  subscription_id     = var.subscription_main_id
}