#### Creation of Azure infra ##########
#######################################

#### Create Azure Resource Group ######
resource "azurerm_resource_group" "rg" {
  name            = var.az_rg_name
  location        = var.az_location

  tags            = var.tags
}

#### Manage Management Groups #########
#######################################

# Define the root Management Group ID
locals {
  root_mg_id = "4c8896b7-52b2-4cb4-9533-1dc0c937e1ed"  # Replace with your actual root MG ID if different
}

# ACME Management Group
module "mg_acme" {
  source       = "../modules/management_group"
  name         = "FPITTELO"
  display_name = "ACME"
  parent_id    = local.root_mg_id
}

# OPR Management Group
module "mg_opr" {
  source       = "../modules/management_group"
  name         = "OPR"
  display_name = "OPR"
  parent_id    = module.mg_acme.id
}

# DEV Management Group
module "mg_dev" {
  source       = "../modules/management_group"
  name         = "dev"
  display_name = "DEV"
  parent_id    = module.mg_opr.id
}

# QA Management Group
module "mg_qa" {
  source       = "../modules/management_group"
  name         = "qa"
  display_name = "QA"
  parent_id    = module.mg_opr.id
}

# MAIN Management Group
module "mg_main" {
  source       = "../modules/management_group"
  name         = "prod"
  display_name = "MAIN"
  parent_id    = module.mg_opr.id
}

# MGT Management Group
module "mg_mgt" {
  source       = "../modules/management_group"
  name         = "MGT"
  display_name = "MGT"
  parent_id    = module.mg_acme.id
}