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

resource contactWebResourceGroup 'Microsoft.Resources/resourceGroups@2018-05-01' = {
  name: rgName
  location: location
}

module sqlServer 'azureSQL.bicep' = {
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
