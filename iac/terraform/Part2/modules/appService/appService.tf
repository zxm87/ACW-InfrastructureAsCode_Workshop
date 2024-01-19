resource "azurerm_service_plan" "cm_hosting_plan" {
  name                = "${var.appServicePlanName}-${var.uniqueIdentifier}"
  resource_group_name = var.resourceGroupName
  location            = var.location
  os_type             = "Windows"
  sku_name            = "F1"  
}

resource "azurerm_windows_web_app" "cm_webapp" {
  name                = "${var.webAppName}-${var.uniqueIdentifier}"
  resource_group_name = var.resourceGroupName
  location            = azurerm_service_plan.cm_hosting_plan.location
  service_plan_id     = azurerm_service_plan.cm_hosting_plan.id    
  identity {
    type = "SystemAssigned"
  }      
    
  site_config {
    always_on = false 
    application_stack {
        dotnet_version = "v6.0"
        current_stack  = "dotnet"
    }              
  }

  app_settings = {    
    "ConnectionStrings:DefaultConnection"   = "@Microsoft.KeyVault(SecretUri=${var.defaultDBSecretURI})"
    "ConnectionStrings:MyContactManager"    = "@Microsoft.KeyVault(SecretUri=${var.managerDBSecretURI})"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.appInsightsConnectionString
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE"       = "true"
    "WEBSITE_RUN_FROM_PACKAGE"              = "1"
  }
}

resource "azurerm_role_assignment" "kv_access_webapp" {
  scope                = var.keyVaultId
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_windows_web_app.cm_webapp.identity[0].principal_id
}