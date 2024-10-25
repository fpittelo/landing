#!/bin/bash

# Initialize Terraform (required to use state commands)
terraform init -input=false

# Declare an associative array of resources to import
declare -A resources=(
  ["module.mg_acme.azurerm_management_group.this"]="FPITTELO"
  ["module.mg_opr.azurerm_management_group.this"]="OPR"
  ["module.mg_dev.azurerm_management_group.this"]="dev"
  ["module.mg_qa.azurerm_management_group.this"]="qa"
  ["module.mg_main.azurerm_management_group.this"]="prod"
  ["module.mg_mgt.azurerm_management_group.this"]="MGT"
  # Add more resources as needed
)

# Loop through each resource
for resource in "${!resources[@]}"; do
  # Check if the resource is already managed
  if ! terraform state list "$resource" &>/dev/null; then
    echo "Importing resource $resource..."
    terraform import "$resource" "${resources[$resource]}"
  else
    echo "Resource $resource is already managed. Skipping import."
  fi
done

# For subscription associations
declare -A subscriptions=(
  ["azurerm_management_group_subscription_association.dev"]="/providers/Microsoft.Management/managementGroups/dev/providers/Microsoft.Management/managementGroupSubscriptions/${SUBSCRIPTION_DEV_ID}"
  ["azurerm_management_group_subscription_association.qa"]="/providers/Microsoft.Management/managementGroups/qa/providers/Microsoft.Management/managementGroupSubscriptions/${SUBSCRIPTION_QA_ID}"
  ["azurerm_management_group_subscription_association.main"]="/providers/Microsoft.Management/managementGroups/prod/providers/Microsoft.Management/managementGroupSubscriptions/${SUBSCRIPTION_MAIN_ID}"
)

for assoc in "${!subscriptions[@]}"; do
  if ! terraform state list "$assoc" &>/dev/null; then
    echo "Importing subscription association $assoc..."
    terraform import "$assoc" "${subscriptions[$assoc]}"
  else
    echo "Subscription association $assoc is already managed. Skipping import."
  fi
done
