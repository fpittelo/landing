#!/bin/bash

set -e

# Import Management Groups
terraform import module.mg_acme.azurerm_management_group.this FPITTELO || true
terraform import module.mg_opr.azurerm_management_group.this OPR || true
terraform import module.mg_dev.azurerm_management_group.this dev || true
terraform import module.mg_qa.azurerm_management_group.this qa || true
terraform import module.mg_main.azurerm_management_group.this prod || true
terraform import module.mg_mgt.azurerm_management_group.this MGT || true

# Import Subscription Associations
terraform import azurerm_management_group_subscription_association.dev /providers/Microsoft.Management/managementGroups/dev/providers/Microsoft.Management/managementGroupSubscriptions/${SUBSCRIPTION_DEV_ID} || true
terraform import azurerm_management_group_subscription_association.qa /providers/Microsoft.Management/managementGroups/qa/providers/Microsoft.Management/managementGroupSubscriptions/${SUBSCRIPTION_QA_ID} || true
terraform import azurerm_management_group_subscription_association.main /providers/Microsoft.Management/managementGroups/prod/providers/Microsoft.Management/managementGroupSubscriptions/${SUBSCRIPTION_MAIN_ID} || true