// Required
variable "resource_group_name" {
  description = "Name of the resource group to place App Gateway in."
}

variable "appgw_name" {
  description = "Name of App Gateway"
}

variable "ag_vnet_name" {
  description = "Name of Virtual Network that the App Gateway will be placed."
}

variable "ag_subnet_id" {
  description = "Subnet Id of Application Gateway."
}

variable "fe_ip_config_name" {
  description = "(Required) The Name of the Frontend IP Configuration used for this HTTP Listener."
}

// Optional
variable "backend_address_pools" {
  description = "List of backend address pools."
  type = list(object({
    name         = string
    ip_addresses = list(string)
    fqdns        = list(string)
  }))
}

variable "backend_http_settings" {
  description = "List of backend HTTP settings."
  type = any
}

variable "http_listeners" {
  description = "List of HTTP/HTTPS listeners. HTTPS listeners require an SSL Certificate object."
  type = any
}

variable "basic_request_routing_rules" {
  description = "Request routing rules to be used for listeners."
  type = any
  default = []
}

variable "redirect_request_routing_rules" {
  description = "Request routing rules to be used for listeners."
  type = any
  default = []
}

variable "path_based_request_routing_rules" {
  description = "Request routing rules to be used for listeners."
  type = any
  default = []
}

variable "ag_sku_name" {
  description = "Name of App Gateway SKU. Options include Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, and WAF_v2"
  default     = "Standard_v2"
}

variable "ag_sku_tier" {
  description = "Tier of App Gateway SKU. Options include Standard, Standard_v2, WAF and WAF_v2"
  default     = "Standard_v2"
}

variable "capacity" {
  description = "(Required) The Capacity of the SKU to use for this Application Gateway. When using a V1 SKU this value must be between 1 and 32, and 1 to 125 for a V2 SKU. This property is optional if autoscale_configuration is set."
  default     = 2
}

variable "frontend_ports" {
  description = "A list of frontend_port blocks as defined below."
  default     = []
  type = list(object({
    name                                      = string
    port                                      = number
  }))
}

variable "probes" {
  description = "Health probes used to test backend health."
  default     = []
  type = any
}

variable "url_path_maps" {
  description = "URL path maps associated to path-based rules."
  default     = []
  type = list(object({
    name                               = string
    default_backend_http_settings_name = string
    default_backend_address_pool_name  = string
    path_rules = list(object({
      name                       = string
      backend_address_pool_name  = string
      backend_http_settings_name = string
      paths                      = list(string)
    }))
  }))
}

variable "ips_allowed" {
  description = "A list of IP addresses to allow to connect to App Gateway."
  default     = []
  type = list(object({
    name         = string
    priority     = number
    ip_addresses = string
  }))
}

variable "redirect_configurations" {
  description = "A collection of redirect configurations."
  default     = []
  type = list(object({
    name                 = string
    redirect_type        = string
    target_listener_name = string
    target_url           = string
    include_path         = bool
    include_query_string = bool
  }))
}

variable "ssl_certificates" {
  description = "SSL Certificate objects to be used for HTTPS listeners. Requires a PFX certificate stored on the machine running the Terraform apply."
  default     = []
  type = list(object({
    name              = string
    pfx_cert_filepath = string
    pfx_cert_password = string
  }))
}

### Public IP 

variable "ag_public_ip_name" {
  description = "Public IP of App GW."
}

variable "ag_allocation_method" {
  description = "(Required) Defines the allocation method for this IP address. Possible values are Static or Dynamic."
  default     = "Static"
}

variable "ag_public_ip_sku" {
  description = "(Optional) The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic."
  default     = "Standard"
}

variable "ag_domain_name_label" {
  description = "Domain name label for Public IP created."
  default = null
}

variable "ag_availability_zone" {
  description = "(Optional) The availability zone to allocate the Public IP in. Possible values are Zone-Redundant, 1, 2, 3, and No-Zone. Defaults to Zone-Redundant."
  default = "Zone-Redundant"
}