param Location string = resourceGroup().location
param FunctionAppName string
param StorageAccountName string
param UserAssignedIdentityResourceId string
param ApplicationInsightsName string
param ResourceGroupID string
param SentinelWorkspaceID string
param ADXClusterURI string
param ADXDatabase string

// Optional parameters
param QueryPackID string = ''
param EventHubResourceID string = ''
param ExistingAppServicePlanResourceId string = ''

// Extract workspace name from the full resource ID for consistent naming
var sentinelWorkspaceResourceParts = split(SentinelWorkspaceID, '/')
var sentinelWorkspaceName = last(sentinelWorkspaceResourceParts)
var hostingPlanName = FunctionAppName

// Define role definition IDs
var monitoringMetricsPublisherRoleId = '3913510d-42f4-4e42-8a64-420c390055eb'
var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', monitoringMetricsPublisherRoleId)

// Conditional logic: Check if Query Pack ID is provided and not empty
var isQueryPackConfigured = !empty(QueryPackID)

// FIXED: Check if Event Hub is configured using Resource ID
var isEventHubConfigured = !empty(EventHubResourceID)

// NEW: Conditional logic for App Service Plan deployment strategy
var useExistingAppServicePlan = !empty(ExistingAppServicePlanResourceId)
var shouldCreateConsumptionPlan = !useExistingAppServicePlan

// NEW: Parse existing App Service Plan details if provided
var existingAppServicePlanResourceIdParts = split(ExistingAppServicePlanResourceId, '/')
var existingAppServicePlanSubscriptionId = useExistingAppServicePlan ? existingAppServicePlanResourceIdParts[2] : subscription().subscriptionId
var existingAppServicePlanResourceGroup = useExistingAppServicePlan ? existingAppServicePlanResourceIdParts[4] : resourceGroup().name
var existingAppServicePlanName = useExistingAppServicePlan ? last(existingAppServicePlanResourceIdParts) : ''

// FIXED: Parse Event Hub Resource ID to extract components for module scope and app settings
var eventHubResourceIdParts = split(EventHubResourceID, '/')
var eventHubSubscriptionId = isEventHubConfigured ? eventHubResourceIdParts[2] : subscription().subscriptionId
var eventHubResourceGroup = isEventHubConfigured ? eventHubResourceIdParts[4] : resourceGroup().name
var eventHubNamespace = isEventHubConfigured ? eventHubResourceIdParts[8] : ''
var eventHubName = isEventHubConfigured ? eventHubResourceIdParts[10] : ''

// Safe extraction of Query Pack resource group (only if configured)
var queryPackResourceIdParts = split(QueryPackID, '/')
var queryPackResourceGroup = isQueryPackConfigured ? queryPackResourceIdParts[4] : resourceGroup().name

// Get existing managed identity resource
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: last(split(UserAssignedIdentityResourceId, '/'))
  scope: resourceGroup((split(UserAssignedIdentityResourceId, '/'))[4])
}

// CONDITIONAL MODULE: Query Pack Permissions (only if Query Pack is configured)
module queryPackPermissions 'modules/querypack-permissions.bicep' = if (isQueryPackConfigured) {
  name: 'querypack-permissions-${FunctionAppName}'
  scope: resourceGroup(queryPackResourceGroup)
  params: {
    queryPackResourceId: QueryPackID
    managedIdentityPrincipalId: managedIdentity.properties.principalId
  }
}

// FIXED CONDITIONAL MODULE: Event Hub Permissions (now deployed to Event Hub's resource group)
module eventHubPermissions 'modules/eventhub-permissions.bicep' = if (isEventHubConfigured) {
  name: 'eventhub-permissions-${FunctionAppName}'
  scope: resourceGroup(eventHubSubscriptionId, eventHubResourceGroup)
  params: {
    eventHubResourceId: EventHubResourceID
    managedIdentityPrincipalId: managedIdentity.properties.principalId
  }
}

// Create Data Collection Endpoint (required for DCRs)
resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2022-06-01' = {
  name: 'dce-${FunctionAppName}-${sentinelWorkspaceName}'
  location: Location
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
    description: 'Data Collection Endpoint for ADX to Log Analytics Scanner'
  }
}

// Role Assignment for the Data Collection Endpoint (DCE)
resource dceRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: dataCollectionEndpoint
  name: guid(dataCollectionEndpoint.id, roleDefinitionResourceId, UserAssignedIdentityResourceId)
  properties: {
    roleDefinitionId: roleDefinitionResourceId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Deploy each DCR using module pattern
module dcrAnomalies 'data-collection-rules/DCR-Anomalies.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-Anomalies'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrASimAuditEventLogs 'data-collection-rules/DCR-ASimAuditEventLogs.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-ASimAuditEventLogs'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrASimAuthenticationEventLogs 'data-collection-rules/DCR-ASimAuthenticationEventLogs.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-ASimAuthenticationEventLogs'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrASimASimDhcpEventLogs 'data-collection-rules/DCR-ASimDhcpEventLogs.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-ASimASimDhcpEventLogs'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrASimDnsActivityLogs 'data-collection-rules/DCR-ASimDnsActivityLogs.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-ASimDnsActivityLogs'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrASimFileEventLogs 'data-collection-rules/DCR-ASimFileEventLogs.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-ASimFileEventLogs'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrASimNetworkSessionLogs 'data-collection-rules/DCR-ASimNetworkSessionLogs.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-ASimNetworkSessionLogs'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrASimProcessEventLogs 'data-collection-rules/DCR-ASimProcessEventLogs.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-ASimProcessEventLogs'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrASimRegistryEventLogs 'data-collection-rules/DCR-ASimRegistryEventLogs.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-ASimRegistryEventLogs'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrASimUserManagementActivityLogs 'data-collection-rules/DCR-ASimUserManagementActivityLogs.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-ASimUserManagementActivityLogs'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrASimWebSessionLogs 'data-collection-rules/DCR-ASimWebSessionLogs.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-ASimWebSessionLogs'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrAWSCloudTrail 'data-collection-rules/DCR-AWSCloudTrail.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-AWSCloudTrail'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrAWSCloudWatch 'data-collection-rules/DCR-AWSCloudWatch.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-AWSCloudWatch'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrAWSGuardDuty 'data-collection-rules/DCR-AWSGuardDuty.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-AWSGuardDuty'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrAWSVPCFlow 'data-collection-rules/DCR-AWSVPCFlow.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-AWSVPCFlow'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrCommonSecurityLog 'data-collection-rules/DCR-CommonSecurityLog.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-CommonSecurityLog'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrGCPAuditLogs 'data-collection-rules/DCR-GCPAuditLogs.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-GCPAuditLogs'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrGoogleCloudSCC 'data-collection-rules/DCR-GoogleCloudSCC.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-GoogleCloudSCC'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrDCRGCPDNSCL 'data-collection-rules/DCR-GCP_DNS_CL.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-GCP_DNS'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrOktaV2_CL 'data-collection-rules/dcr-OktaV2_CL.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-OktaV2_CL'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrSecurityEvent 'data-collection-rules/DCR-SecurityEvent.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-SecurityEvent'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrSyslog 'data-collection-rules/DCR-Syslog.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-Syslog'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

module dcrWindowsEvent 'data-collection-rules/DCR-WindowsEvent.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-WindowsEvent'
  params: {
    location: Location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    servicePrincipalObjectId: managedIdentity.properties.principalId
    workspaceResourceId: SentinelWorkspaceID
    workspaceName: sentinelWorkspaceName
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: StorageAccountName
  location: Location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}

// NEW: Reference existing App Service Plan if provided
resource existingAppServicePlan 'Microsoft.Web/serverfarms@2021-03-01' existing = if (useExistingAppServicePlan) {
  name: existingAppServicePlanName
  scope: resourceGroup(existingAppServicePlanSubscriptionId, existingAppServicePlanResourceGroup)
}

// CONDITIONAL: Create Consumption Plan only if not using existing App Service Plan
resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = if (shouldCreateConsumptionPlan) {
  name: hostingPlanName
  location: Location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: ApplicationInsightsName
  location: Location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

// NEW: Function App now uses dynamic reference to either existing or new hosting plan
resource functionApp 'Microsoft.Web/sites@2020-12-01' = {
  name: FunctionAppName
  location: Location
  kind: 'functionapp'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${UserAssignedIdentityResourceId}': {}
    }
  }
  properties: {
    httpsOnly: true
    serverFarmId: useExistingAppServicePlan ? existingAppServicePlan.id : hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'powershell'
        }      
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${StorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${StorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(FunctionAppName)
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME_VERSION'
          value: '~7.4'
        }
        {
          name: 'ExternalDurablePowerShellSDK'
          value: 'true'
        } 
        {
          name: 'DurableManagementStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${StorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'DURABLE_FUNCTIONS_HUB_NAME'
          value: 'ADXLogAnalyticsScannerHub'
        }
        {
          name: 'DURABLE_TASK_EXTENSION_VERSION'
          value: '~2.0'
        }
        {
          name: 'EVENTHUBNAMESPACE'
          value: eventHubNamespace
        }
        {
          name: 'EVENTHUBNAME'
          value: eventHubName
        }  
        {
          name: 'ADXCLUSTERURI'
          value: ADXClusterURI
        }  
        {
          name: 'ADXDATABASE'
          value: ADXDatabase
        }  
        {
          name: 'QUERYPACKID'
          value: QueryPackID
        }
        {
          name: 'CLIENTID'
          value: managedIdentity.properties.clientId
        }
        {
          name: 'DCRAnomalies'
          value: dcrAnomalies.outputs.immutableId
        }
        {
          name: 'DCRASimAuditEventLogs'
          value: dcrASimAuditEventLogs.outputs.immutableId
        }
        {
          name: 'DCRASimAuthenticationEventLogs'
          value: dcrASimAuthenticationEventLogs.outputs.immutableId
        }
        {
          name: 'DCRASimDhcpEventLogs'
          value: dcrASimASimDhcpEventLogs.outputs.immutableId
        }
        {
          name: 'DCRASimDnsActivityLogs'
          value: dcrASimDnsActivityLogs.outputs.immutableId
        }
        {
          name: 'DCRASimFileEventLogs'
          value: dcrASimFileEventLogs.outputs.immutableId
        }
        {
          name: 'DCRASimNetworkSessionLogs'
          value: dcrASimNetworkSessionLogs.outputs.immutableId
        }
        {
          name: 'DCRASimProcessEventLogs'
          value: dcrASimProcessEventLogs.outputs.immutableId
        }
        {
          name: 'DCRASimRegistryEventLogs'
          value: dcrASimRegistryEventLogs.outputs.immutableId
        }
        {
          name: 'DCRASimUserManagementActivityLogs'
          value: dcrASimUserManagementActivityLogs.outputs.immutableId
        }
        {
          name: 'DCRASimWebSessionLogs'
          value: dcrASimWebSessionLogs.outputs.immutableId
        }
        {
          name: 'DCRAWSCloudTrail'
          value: dcrAWSCloudTrail.outputs.immutableId
        }
        {
          name: 'DCRAWSCloudWatch'
          value: dcrAWSCloudWatch.outputs.immutableId
        }
        {
          name: 'DCRAWSGuardDuty'
          value: dcrAWSGuardDuty.outputs.immutableId
        }
        {
          name: 'DCRAWSVPCFlow'
          value: dcrAWSVPCFlow.outputs.immutableId
        }
        {
          name: 'DCRCommonSecurityLog'
          value: dcrCommonSecurityLog.outputs.immutableId
        }
        {
          name: 'DCRGCPAuditLogs'
          value: dcrGCPAuditLogs.outputs.immutableId
        }
        {
          name: 'DCRGCP_DNS_CL'
          value: dcrDCRGCPDNSCL.outputs.immutableId
        }
        {
          name: 'DCRGoogleCloudSCC'
          value: dcrGoogleCloudSCC.outputs.immutableId
        }
        {
          name: 'dcrOktaV2_CL'
          value: dcrOktaV2_CL.outputs.immutableId
        }
        {
          name: 'DCRSecurityEvent'
          value: dcrSecurityEvent.outputs.immutableId
        }
        {
          name: 'DCRSyslog'
          value: dcrSyslog.outputs.immutableId
        }
        {
          name: 'DCRWindowsEvent'
          value: dcrWindowsEvent.outputs.immutableId
        }
        {
          name: 'DATA_COLLECTION_ENDPOINT_ID'
          value: dataCollectionEndpoint.id
        }
        {
          name: 'DATA_COLLECTION_ENDPOINT_URL'
          value: dataCollectionEndpoint.properties.logsIngestion.endpoint
        }
        {
          name: 'SENTINEL_WORKSPACE_ID'
          value: SentinelWorkspaceID
        }
        {
          name: 'SENTINEL_WORKSPACE_NAME'
          value: sentinelWorkspaceName
        }
        {
          name: 'FUNCTIONS_WORKER_PROCESS_COUNT'
          value: '1'
        }                                                   
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
      use32BitWorkerProcess: false
      powerShellVersion: '~7'
      functionAppScaleLimit: 200
    }
  }
}

output functionAppName string = functionApp.name
output functionAppId string = functionApp.id
output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output applicationInsightsName string = applicationInsights.name
output applicationInsightsId string = applicationInsights.id
output managedIdentityClientId string = managedIdentity.properties.clientId
output dceRoleAssignmentId string = dceRoleAssignment.id
output dceRoleAssignmentPrincipalId string = dceRoleAssignment.properties.principalId
output dataCollectionEndpointId string = dataCollectionEndpoint.id
output ResourceGroupID string = ResourceGroupID
output queryPackConfigured bool = isQueryPackConfigured
output eventHubConfigured bool = isEventHubConfigured
output usingExistingAppServicePlan bool = useExistingAppServicePlan
output hostingPlanId string = useExistingAppServicePlan ? existingAppServicePlan.id : hostingPlan.id
output hostingPlanName string = useExistingAppServicePlan ? existingAppServicePlanName : hostingPlanName
