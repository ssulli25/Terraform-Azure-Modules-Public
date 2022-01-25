#############################################################################
# Resource Group Data
#############################################################################

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

#############################################################################
# Automation Account
#############################################################################

resource "azurerm_automation_account" "automation_account" {
  name                = var.automation_account_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  sku_name            = "Basic"

  tags     = var.extra_tags
}

#############################################################################
# Link automation account to log analytics workspace
#############################################################################

resource "azurerm_log_analytics_linked_service" "link_workspace_automation" {
  count = var.log_analytics_workspace_link_enabled ? 1 : 0

  resource_group_name = coalesce(var.log_analytics_resource_group_name, var.resource_group_name)
  workspace_id        = var.log_analytics_workspace_id
  read_access_id      = azurerm_automation_account.automation_account.id
}