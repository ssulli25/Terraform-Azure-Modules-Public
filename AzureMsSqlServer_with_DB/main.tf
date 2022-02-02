data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}


resource "azurerm_mssql_server" "sql-server" {
  name                         = var.sql_server_name
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = coalesce(var.location, data.azurerm_resource_group.rg.location)
  version                      = var.server_version
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = var.minimum_tls_version
  tags                         = var.sql_tags

  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator != "" ? [var.azuread_administrator] : []
    content {
      azuread_authentication_only = lookup(azuread_administrator.value, "azuread_authentication_only", false)
      login_username              = lookup(azuread_administrator.value, "login_username", null) 
      object_id                   = lookup(azuread_administrator.value, "object_id", null)
      tenant_id                   = lookup(azuread_administrator.value, "tenant_id", null)
    }
  }
}

resource "azurerm_mssql_database" "sql-db" {
  count                            = length(var.database_names) 
  name                             = var.database_names[count.index]
  server_id                        = azurerm_mssql_server.sql-server.id
  collation                        = var.collation
  license_type                     = var.license_type
  sku_name                         = var.sql_sku_name
  zone_redundant                   = var.sql_zone_redundant
  create_mode                      = var.create_mode
  elastic_pool_id                  = var.enable_elasticpool == true ? azurerm_mssql_elasticpool.elastic_pool[0].id : null

  tags                             = var.database_tags

}

### Elastic Pool

resource "azurerm_mssql_elasticpool" "elastic_pool" {
  count               = var.enable_elasticpool ? 1 : 0
  name                = var.elastic_pool_name
  location            = coalesce(var.location, data.azurerm_resource_group.rg.location)
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_mssql_server.sql-server.name
  max_size_gb         = var.elastic_pool_max_size
  zone_redundant      = var.sql_zone_redundant

  per_database_settings {
    max_capacity = var.database_max_capacity
    min_capacity = var.database_min_capacity
  }

   sku {
      capacity = var.elastic_sku.capacity
      tier     = var.elastic_sku.tier
      name     = var.elastic_sku.name
  }
}