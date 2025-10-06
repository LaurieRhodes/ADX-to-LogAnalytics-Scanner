@description('The location of the resources')
param location string = 'Australia East'
@description('The name of the Data Collection Endpoint Id')
param dataCollectionEndpointId string
@description('The Log Analytics Workspace Id used for Sentinel')
param workspaceResourceId string
@description('The Target Sentinel workspace name')
param workspaceName string = 'sentinel-workspace'
@description('The Service Principal Object ID of the Entra App')
param servicePrincipalObjectId string

// ============================================================================
// Data Collection Rule for GCPAuditLogs
// ============================================================================
// Generated: 2025-09-18 07:50:24
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 27, DCR columns: 26 (Type column always filtered)
// Input stream: Custom-GCPAuditLogs (always Custom- for JSON ingestion)
// Output stream: Microsoft-GCPAuditLogs (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-GCPAuditLogs'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-GCPAuditLogs': {
        columns: [
          {
            name: 'TimeGenerated'
            type: 'string'
          }
          {
            name: 'TenantId'
            type: 'string'
          }
          {
            name: 'ServiceData'
            type: 'dynamic'
          }
          {
            name: 'ResourceOriginalState'
            type: 'dynamic'
          }
          {
            name: 'ResourceLocation'
            type: 'dynamic'
          }
          {
            name: 'Subscription'
            type: 'string'
          }
          {
            name: 'GCPResourceType'
            type: 'string'
          }
          {
            name: 'Severity'
            type: 'string'
          }
          {
            name: 'ProjectId'
            type: 'string'
          }
          {
            name: 'Timestamp'
            type: 'string'
          }
          {
            name: 'LogName'
            type: 'string'
          }
          {
            name: 'PrincipalEmail'
            type: 'string'
          }
          {
            name: 'InsertId'
            type: 'string'
          }
          {
            name: 'StatusMessage'
            type: 'string'
          }
          {
            name: 'Response'
            type: 'dynamic'
          }
          {
            name: 'Request'
            type: 'dynamic'
          }
          {
            name: 'RequestMetadata'
            type: 'dynamic'
          }
          {
            name: 'AuthorizationInfo'
            type: 'dynamic'
          }
          {
            name: 'AuthenticationInfo'
            type: 'dynamic'
          }
          {
            name: 'Status'
            type: 'dynamic'
          }
          {
            name: 'NumResponseItems'
            type: 'string'
          }
          {
            name: 'GCPResourceName'
            type: 'string'
          }
          {
            name: 'MethodName'
            type: 'string'
          }
          {
            name: 'ServiceName'
            type: 'string'
          }
          {
            name: 'Metadata'
            type: 'dynamic'
          }
          {
            name: 'SourceSystem'
            type: 'string'
          }
        ]
      }
    }
    dataSources: {}
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceResourceId
          name: 'Sentinel-GCPAuditLogs'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-GCPAuditLogs']
        destinations: ['Sentinel-GCPAuditLogs']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), ServiceData = todynamic(ServiceData), ResourceOriginalState = todynamic(ResourceOriginalState), ResourceLocation = todynamic(ResourceLocation), Subscription = tostring(Subscription), GCPResourceType = tostring(GCPResourceType), Severity = tostring(Severity), ProjectId = tostring(ProjectId), Timestamp = todatetime(Timestamp), LogName = tostring(LogName), PrincipalEmail = tostring(PrincipalEmail), InsertId = tostring(InsertId), StatusMessage = tostring(StatusMessage), Response = todynamic(Response), Request = todynamic(Request), RequestMetadata = todynamic(RequestMetadata), AuthorizationInfo = todynamic(AuthorizationInfo), AuthenticationInfo = todynamic(AuthenticationInfo), Status = todynamic(Status), NumResponseItems = tostring(NumResponseItems), GCPResourceName = tostring(GCPResourceName), MethodName = tostring(MethodName), ServiceName = tostring(ServiceName), Metadata = todynamic(Metadata), SourceSystem = tostring(SourceSystem)'
        outputStream: 'Microsoft-GCPAuditLogs'
      }
    ]
  }
}

// Role Assignment to the DCR
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: dataCollectionRule
  name: guid(resourceGroup().id, roleDefinitionResourceId, dataCollectionRule.name)
  properties: {
    roleDefinitionId: roleDefinitionResourceId
    principalId: servicePrincipalObjectId
    principalType: 'ServicePrincipal'
  }
}

output immutableId string = dataCollectionRule.properties.immutableId
output dataCollectionRuleId string = dataCollectionRule.id
output dataCollectionRuleName string = dataCollectionRule.name
