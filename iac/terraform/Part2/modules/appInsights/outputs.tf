output "appInsightsConnectionString" {
  value = azurerm_application_insights.cm_app_insights.connection_string
}