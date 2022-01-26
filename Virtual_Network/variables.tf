#############################################################################
# RESOURCE Group Data Variable
#############################################################################

variable "resource_group_name" {
  description = "The name of an existing resource group to be imported."
  type        = string
}

#############################################################################
# Virtual Network Variables
#############################################################################

variable "vnet_name" {
  description = "Name of the vnet to create."
  type        = string
}

variable "vnet_location" {
  description = "The location of the vnet to create. Defaults to the location of the resource group."
  type        = string
  default     = null
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  type        = list(string)
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  type        = list(string)
  default     = []
}

#############################################################################
# Subnet Variables
#############################################################################

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  type        = list(string)
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  type        = list(string)
}

variable "subnet_service_endpoints" {
  description = "A map of subnet name to service endpoints to add to the subnet."
  type        = map(any)
  default     = {}
}

variable "subnet_enforce_private_link_endpoint_network_policies" {
  description = "A map of subnet name to enable/disable private link endpoint network policies on the subnet."
  type        = map(bool)
  default     = {}
}

variable "subnet_enforce_private_link_service_network_policies" {
  description = "A map of subnet name to enable/disable private link service network policies on the subnet."
  type        = map(bool)
  default     = {}
}

#############################################################################
# NSG Variables
#############################################################################

variable "nsg_ids" {
  description = "A map of subnet name to Network Security Group IDs"
  type        = map(string)

  default = {
  }
}

#############################################################################
# Route Table Variables
#############################################################################

variable "route_tables_ids" {
  description = "A map of subnet name to Route table ids"
  type        = map(string)
  default     = {}
}

#############################################################################
# Network Tags
#############################################################################

variable "network_tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {}
}
