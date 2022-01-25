#############################################################################
# RESOURCE Group Data
#############################################################################

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

#############################################################################
# Azure Role Assignment
#############################################################################

resource "azurerm_role_assignment" "logs" {
  count                = length(var.contributors)
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Log Analytics Contributor"
  principal_id         = var.contributors[count.index]
}

#############################################################################
# Log Analytics Workspace
#############################################################################

resource "azurerm_log_analytics_workspace" "logs" {
  name                = var.name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days

  tags = var.tags
}

#############################################################################
# Security Center Integration
#############################################################################

resource "azurerm_security_center_workspace" "logs" {
  count        = length(var.security_center_subscription)
  scope        = "/subscriptions/${element(var.security_center_subscription, count.index)}"
  workspace_id = azurerm_log_analytics_workspace.logs.id
}

#############################################################################
# Log Analytics Solution
#############################################################################

resource "azurerm_log_analytics_solution" "logs" {
  count                 = length(var.solutions)
  solution_name         = var.solutions[count.index].solution_name
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.logs.id
  workspace_name        = azurerm_log_analytics_workspace.logs.name

  plan {
    publisher = var.solutions[count.index].publisher
    product   = var.solutions[count.index].product
  }

  # Example for AKS Cluster
  #   plan {
  #   publisher = "Microsoft"
  #   product   = "OMSGallery/ContainerInsights"
  # }

  tags = var.tags
}