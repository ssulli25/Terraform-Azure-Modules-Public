output "app_service_plan_name" {
  description = "Name of the app service plan."
  value       = azurerm_app_service_plan.main.name
}

output "app_service_plan_id" {
  description = "Id of the app service plan."
  value       = azurerm_app_service_plan.main.id
}

output "app_insight_instrument_key" {
  description = "Instrumentation key of the application insight."
  value       = azurerm_application_insights.main[0].instrumentation_key
}

output "app_insight_name" {
  description = "Name of the application insight."
  value       = azurerm_application_insights.main[0].name
}

output "app_service_default_site_hostname" {
  description = "The Default Hostname associated with the App Service"
  value       = azurerm_app_service.main.default_site_hostname
}