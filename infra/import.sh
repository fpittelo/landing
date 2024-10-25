#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Ensure ENVIRONMENT and PROJECT_NAME variables are set
ENVIRONMENT="${ENVIRONMENT:-dev}"
PROJECT_NAME="${PROJECT_NAME:-azurelanding}"

# Compute backend resource names
az_backend_rg_name="${ENVIRONMENT}-bkd-${PROJECT_NAME}"
az_backend_sa_name="${ENVIRONMENT}bkd${PROJECT_NAME}sa"
az_backend_sa_name=$(echo "$az_backend_sa_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
az_backend_sa_name=${az_backend_sa_name:0:24}
az_backend_container_name="${ENVIRONMENT}-bkd-${PROJECT_NAME}-co"

# Export variables as TF_VAR_ environment variables
export TF_VAR_az_backend_container_name="$az_backend_container_name"
export TF_VAR_az_backend_rg_name="$az_backend_rg_name"
export TF_VAR_az_backend_sa_name="$az_backend_sa_name"

# Optionally, disable interactive prompts
export TF_INPUT=0

VAR_FILE="${ENVIRONMENT}.tfvars"

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
)

# Loop through each resource
for resource in "${!resources[@]}"; do
  if ! terraform state list "$resource" &>/dev/null; then
    echo "Importing resource $resource..."
    terraform import -input=false "$resource" "${resources[$resource]}"
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
    terraform import -input=false -var-file="${VAR_FILE}" "$assoc" "${subscriptions[$assoc]}"
  else
    echo "Subscription association $assoc is already managed. Skipping import."
  fi
done