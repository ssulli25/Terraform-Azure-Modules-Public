data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_public_ip" "publicip" {
  name                = var.public_ip_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = var.allocation_method
  sku                 = var.public_ip_sku
  domain_name_label   = var.domain_name_label
  availability_zone   = var.availability_zone
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  frontend_ip_configuration_name = var.fe_ip_config_name
}

resource "azurerm_application_gateway" "app-gateway" {
  name                = var.appgw_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.publicip.id
  }

  dynamic "frontend_port" {
    for_each = var.frontend_ports
    content {
      name = lookup(frontend_port.value, "name", null)
      port = lookup(frontend_port.value, "port", null)
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = lookup(backend_address_pool.value, "name", null)
      ip_addresses = lookup(backend_address_pool.value, "ip_addresses", null)
      fqdns        = lookup(backend_address_pool.value, "fqdns", null)
    }
  }

    dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = lookup(backend_http_settings.value, "name", null)
      cookie_based_affinity               = lookup(backend_http_settings.value, "cookie_based_affinity", "Disabled")
      path                                = lookup(backend_http_settings.value, "path", null)
      port                                = backend_http_settings.value.https_enabled ? "443" : "80"
      protocol                            = backend_http_settings.value.https_enabled ? "Https" : "Http"
      request_timeout                     = lookup(backend_http_settings.value, "request_timeout", 60)
      probe_name                          = lookup(backend_http_settings.value, "probe_name", null)
      pick_host_name_from_backend_address = lookup(backend_http_settings.value, "pick_host_name_from_backend_address", true)
      host_name                           = lookup(backend_http_settings.value, "host_name", null)
      
    }
  }

    dynamic "probe" {
    for_each = var.probes
    content {
      interval                                  = lookup(probe.value, "interval", 30)
      name                                      = lookup(probe.value, "name")
      path                                      = lookup(probe.value, "path")
      protocol                                  = lookup(probe.value, "protocol")
      timeout                                   = lookup(probe.value, "timeout", 30)
      unhealthy_threshold                       = lookup(probe.value, "unhealthy_threshold", 3)
      pick_host_name_from_backend_http_settings = lookup(probe.value, "pick_host_name_from_backend_http_settings", true)
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                            = lookup(http_listener.value, "name")
      frontend_ip_configuration_name  = lookup(http_listener.value, "frontend_ip_configuration_name", local.frontend_ip_configuration_name)
      frontend_port_name              = lookup(http_listener.value, "frontend_port_name")
      protocol                        = lookup(http_listener.value, "protocol")
      host_name                       = lookup(http_listener.value, "host_name", null)
      host_names                      = lookup(http_listener.value, "host_names", null)
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates
    content {
      name     = ssl_certificate.value.name
      data     = filebase64(ssl_certificate.value.pfx_cert_filepath)
      password = ssl_certificate.value.pfx_cert_password
    }
  }

  // Basic Rules
  dynamic "request_routing_rule" {
    for_each = var.basic_request_routing_rules
    content {
      name                        = lookup(request_routing_rule.value, "name")
      rule_type                   = lookup(request_routing_rule.value, "rule_type", "Basic")
      http_listener_name          = lookup(request_routing_rule.value, "http_listener_name")
      backend_address_pool_name   = lookup(request_routing_rule.value, "backend_address_pool_name")
      backend_http_settings_name  = lookup(request_routing_rule.value, "backend_http_settings_name")
    }
  }

  // Redirect Rules
  dynamic "request_routing_rule" {
    for_each = var.redirect_request_routing_rules
    content {
      name                        = lookup(request_routing_rule.value, "name")
      rule_type                   = lookup(request_routing_rule.value, "rule_type", "Basic")
      http_listener_name          = lookup(request_routing_rule.value, "http_listener_name")
      redirect_configuration_name = lookup(request_routing_rule.value, "redirect_configuration_name")
    }
  }

  // Path based rules
  dynamic "request_routing_rule" {
    for_each = var.path_based_request_routing_rules
    content {
      name                        = lookup(request_routing_rule.value, "name")
      rule_type                   = lookup(request_routing_rule.value, "rule_type","PathBasedRouting")
      http_listener_name          = lookup(request_routing_rule.value, "http_listener_name")
      url_path_map_name           = lookup(request_routing_rule.value, "url_path_map_name", null)
    }
  }

  dynamic "url_path_map" {
    for_each = var.url_path_maps
    content {
      name                               = url_path_map.value.name
      default_backend_http_settings_name = url_path_map.value.default_backend_http_settings_name
      default_backend_address_pool_name  = url_path_map.value.default_backend_address_pool_name

      dynamic "path_rule" {
        for_each = url_path_map.value.path_rules
        content {
          name                       = path_rule.value.name
          backend_address_pool_name  = path_rule.value.backend_address_pool_name
          backend_http_settings_name = path_rule.value.backend_http_settings_name
          paths                      = path_rule.value.paths
        }
      }
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.redirect_configurations
    content {
      name                 = redirect_configuration.value.name
      redirect_type        = redirect_configuration.value.redirect_type
      target_listener_name = redirect_configuration.value.target_listener_name
      target_url           = redirect_configuration.value.target_url
      include_path         = redirect_configuration.value.include_path
      include_query_string = redirect_configuration.value.include_query_string
    }
  }
}