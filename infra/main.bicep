targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Optional parameters to override the default azd resource naming conventions. Update the main.parameters.json file to provide values. e.g.,:
// "resourceGroupName": {
//      "value": "myGroupName"
// }
param apiServiceName string = ''
param applicationInsightsDashboardName string = ''
param applicationInsightsName string = ''
param appServicePlanName string = ''
param appServicePlanNameWeb string = ''
param keyVaultName string = ''
param logAnalyticsName string = ''
param resourceGroupName string = ''
param storageAccountName string = ''
param webServiceName string = ''

@description('Id of the user or app to assign application roles')
param principalId string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

// web app
module web './app/web.bicep' = {
  name: 'web'
  scope: rg
  params: {
    name: !empty(webServiceName) ? webServiceName : '${abbrs.webSitesAppService}web-${resourceToken}'
    location: location
    tags: tags
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    appServicePlanId: appServicePlanWeb.outputs.id
    appSettings: {     
      KEYVAULT_NAME: keyVault.outputs.name
    }
  }
}

// Func App
module func './app/func.bicep' = {
  name: 'func'
  scope: rg
  params: {
    name: !empty(apiServiceName) ? apiServiceName : '${abbrs.webSitesFunctions}playwright-${resourceToken}'
    location: location
    tags: tags
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    appServicePlanId: appServicePlan.outputs.id
    keyVaultName: keyVault.outputs.name
    storageAccountName: storage.outputs.name
    appSettings: {
      PLAYWRIGHT_BROWSERS_PATH: 0
      POST_BUILD_COMMAND: 'scripts/postbuild.sh'
      WEBAPP_URI: web.outputs.SERVICE_WEB_URI
    }
  }
}

// Give the API access to KeyVault
module apiKeyVaultAccess './core/security/keyvault-access.bicep' = {
  name: 'api-keyvault-access'
  scope: rg
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: func.outputs.SERVICE_API_IDENTITY_PRINCIPAL_ID
  }
}

// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan './core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: rg
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}func'
    location: location
    tags: tags
    sku: {
      name: 'Y1'
      tier: 'Dynamic'
    }
  }
}


// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlanWeb './core/host/appserviceplan.bicep' = {
  name: 'appserviceplanweb'
  dependsOn: [
    appServicePlan
  ]
  scope: rg
  params: {
    name: !empty(appServicePlanNameWeb) ? appServicePlanNameWeb : '${abbrs.webServerFarms}${resourceToken}web'
    location: location
    tags: tags
    sku: {
      name: 'S1'
    }
  }
}

// Backing storage for Azure functions backend API
module storage './core/storage/storage-account.bicep' = {
  name: 'storage'
  scope: rg
  params: {
    name: !empty(storageAccountName) ? storageAccountName : '${abbrs.storageStorageAccounts}${resourceToken}'
    location: location
    tags: tags
  }
}

// Store secrets in a keyvault
module keyVault './core/security/keyvault.bicep' = {
  name: 'keyvault'
  scope: rg
  params: {
    name: !empty(keyVaultName) ? keyVaultName : '${abbrs.keyVaultVaults}${resourceToken}'
    location: location
    tags: tags
    principalId: principalId
  }
}

// Monitor application with Azure Monitor
module monitoring './core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: rg
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${resourceToken}'
  }
}

// App outputs
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
