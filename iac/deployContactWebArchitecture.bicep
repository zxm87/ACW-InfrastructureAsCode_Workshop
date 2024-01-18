targetScope = 'subscription'

param rgName string
param location string
param clientIPAddress string
param sqlServerName string
param sqlDatabaseName string
param sqlServerAdminLogin string
@secure()
param sqlServerAdminPassword string
param uniqueIdentifier string
param logAnalyticsWorkspaceName string
param appInsightsName string
param webAppName string
param appServicePlanName string
param appServicePlanSku string
param identityDBConnectionStringKey string
param managerDBConnectionStringKey string
param appInsightsConnectionStringKey string
param keyVaultName string
param developersGroupObjectId string
param keyVaultUserManagedIdentityName string
var keyVaultUMIFullName = '${keyVaultName}-${keyVaultUserManagedIdentityName}'

resource contactWebResourceGroup 'Microsoft.Resources/resourceGroups@2018-05-01' = {
  name: rgName
  location: location
}

module contactWebDatabase 'azureSQL.bicep' = {
  scope: contactWebResourceGroup
  params: {
    clientIPAddress: clientIPAddress
    sqlDatabaseName: sqlDatabaseName
    sqlServerAdminLogin: sqlServerAdminLogin
    sqlServerAdminPassword: sqlServerAdminPassword
    sqlServerName: sqlServerName
    uniqueIdentifier: uniqueIdentifier
    location: location
  }
  name: sqlServerName
}

module contactWebAnalyticsWorkspace 'logAnalyticsWorkspace.bicep' = {
  name: '${logAnalyticsWorkspaceName}-deployment'
  scope: contactWebResourceGroup
  params: {
    location: contactWebResourceGroup.location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

module contactWebApplicationInsights 'applicationInsights.bicep' = {
  name: '${appInsightsName}-deployment'
  scope: contactWebResourceGroup
  params: {
    location: contactWebResourceGroup.location
    appInsightsName: appInsightsName
    logAnalyticsWorkspaceId: contactWebAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
  }
}

module contactWebApplicationPlanAndSite 'contactWebAppService.bicep' = {
  name: '${webAppName}-deployment'
  scope: contactWebResourceGroup
  params: {
    location: contactWebResourceGroup.location
    uniqueIdentifier: uniqueIdentifier
    appInsightsName: contactWebApplicationInsights.outputs.applicationInsightsName
    appServicePlanName: appServicePlanName
    appServicePlanSku: appServicePlanSku
    webAppName: webAppName
    identityDBConnectionStringKey: identityDBConnectionStringKey
    managerDBConnectionStringKey: managerDBConnectionStringKey
    appInsightsConnectionStringKey: appInsightsConnectionStringKey
  }
}

module contactWebVault 'keyVault.bicep' = {
  name: '${keyVaultName}-deployment'
  scope: contactWebResourceGroup
  params: {
    location: contactWebResourceGroup.location
    uniqueIdentifier: uniqueIdentifier
    webAppFullName: contactWebApplicationPlanAndSite.outputs.webAppFullName
    databaseServerName: contactWebDatabase.outputs.sqlServerName
    keyVaultName: keyVaultName
    sqlDatabaseName: sqlDatabaseName
    sqlServerAdminPassword: sqlServerAdminPassword
    developersGroupObjectId: developersGroupObjectId
    keyVaultUserManagedIdentityName: keyVaultUMIFullName
  }
}

module updateContactWebAppSettings 'contactWebAppServiceSettingsUpdate.bicep' = {
  name: '${webAppName}-updatingAppSettings'
  scope: contactWebResourceGroup
  params: {
    webAppName: contactWebApplicationPlanAndSite.outputs.webAppFullName
    defaultDBSecretURI: contactWebVault.outputs.identityDBConnectionSecretURI
    managerDBSecretURI: contactWebVault.outputs.managerDBConnectionSecretURI
    identityDBConnectionStringKey: identityDBConnectionStringKey
    managerDBConnectionStringKey: managerDBConnectionStringKey
  }
}
