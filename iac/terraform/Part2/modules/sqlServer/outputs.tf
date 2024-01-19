output "sqlServerName" {
  value = azurerm_mssql_server.cm_sql_server.name
}

output "sqlServerFQDN" {
  value = azurerm_mssql_server.cm_sql_server.fully_qualified_domain_name
}

output "sqlServerAdminLogin" {
  value = azurerm_mssql_server.cm_sql_server.administrator_login
}