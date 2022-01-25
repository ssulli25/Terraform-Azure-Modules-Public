
#############################################################################
# Shared Variables
#############################################################################

variable "resource_group_name" {
  type = string
}

variable "location" {
  description = "Azure location for SQL Server."
  type        = string
}

#############################################################################
# Azure SQL Server Variables
#############################################################################

variable "sql_server" {
  description = "Name of Azure SQL server instance being created"
  type        = string
}

variable "server_version" {
  description = "(Required) The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server)."
  type        = string
  default     = "12.0"
}

variable "admin_login" {
  description = "(Required) The administrator login name for the new server. Changing this forces a new resource to be created."
  type        = string
  default     = "azadmin"
}

variable "admin_password" {
  description = "(Required) The password associated with the administrator_login user. Needs to comply with Azure's Password Policy"
  type        = string
  default     = "NotAPassword01"
}

variable "azuread_administrator" {
  description = "The login username of the Azure AD Administrator of this SQL Server."
  type        = any
  default     = ""
}

variable "minimum_tls_version" {
  description = "(Optional) The Minimum TLS Version for all SQL Database and SQL Data Warehouse databases associated with the server. Valid values are: 1.0, 1.1 and 1.2."
  type        = string
  default     = "1.2"
}

variable "sql_tags" {
  description = "SQL Server Tags."
  type        = map(string)
  default     = {}
}

#############################################################################
# Azure SQL Database Variables
#############################################################################

variable "database_names" {
  description = "Names of the databases to create for this server"
  type        = list(string)
  default     = []
}

variable "license_type" {
  description = "(Optional) Specifies the license type applied to this database. Possible values are LicenseIncluded and BasePrice."
  type        = string
  default     = "LicenseIncluded"
}

variable "sku_name" {
  description = "(Optional) Specifies the name of the sku used by the database. Changing this forces a new resource to be created. For example, GP_S_Gen5_2,HS_Gen4_1,BC_Gen5_2, ElasticPool, Basic,S0, P2 ,DW100c, DS100."
  type        = string
  default     = null
}

variable "create_mode" {
  description = "(Optional) Specifies how to create the database. Valid values are: Default, Copy, OnlineSecondary, NonReadableSecondary, PointInTimeRestore, Recovery, Restore or RestoreLongTermRetentionBackup. Must be Default to create a new database. Defaults to Default."
  type        = string
  default     = "Default"
}

variable "collation" {
  description = "(Optional) The name of the collation. Applies only if create_mode is Default. Azure default is SQL_LATIN1_GENERAL_CP1_CI_AS. Changing this forces a new resource to be created."
  type        = string
  default     = "SQL_LATIN1_GENERAL_CP1_CI_AS"
}

variable "zone_redundant" {
  description = "(Optional) Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones. This property is only settable for Premium and Business Critical databases."
  type        = bool
  default     = false
}

variable "database_tags" {
  description = "Database Tags."
  type        = map(string)
  default     = {}
}

#############################################################################
# Elastic Pool
#############################################################################

variable "enable_elasticpool" {
  description = "Deploy the databases in an ElasticPool if enabled. Otherwise, deploy single databases."
  type        = bool
  default     = false
}

variable "elastic_pool_max_size" {
  description = "Maximum size of the Elastic Pool in gigabytes"
  type        = string
  default     = null
}

variable "elastic_sku" {
  description = <<DESC
    SKU for the Elastic Pool with tier and eDTUs capacity. Premium tier with zone redundancy is mandatory for high availability.
    Possible values for tier are "GP_Gen5", "BC_Gen5" for vCore models and "Basic", "Standard", or "Premium" for DTU based models. Example {tier="Standard", capacity="50"}.
    See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-dtu-resource-limits-elastic-pools"
DESC

  type = object({
    tier     = string,
    name     = string,
    capacity = number
  })
  default = null
}

variable "database_min_capacity" {
  description = "The minimum capacity (DTU or vCore) all databases are guaranteed in the Elastic Pool. Defaults to 0."
  type        = string
  default     = "0"
}

variable "database_max_capacity" {
  description = "The maximum capacity (DTU or vCore) any one database can consume in the Elastic Pool. Default to the max Elastic Pool capacity."
  type        = string
  default     = ""
}

variable "elastic_pool_name" {
  description = "Name of the SQL Elastic Pool, generated if not set."
  type        = string
  default     = ""
}