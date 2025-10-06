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
// Data Collection Rule for AWSGuardDuty
// ============================================================================
// Generated: 2025-09-18 07:50:18
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 17, DCR columns: 16 (Type column always filtered)
// Input stream: Custom-AWSGuardDuty (always Custom- for JSON ingestion)
// Output stream: Microsoft-AWSGuardDuty (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-AWSGuardDuty'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-AWSGuardDuty': {
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
            name: 'SchemaVersion'
            type: 'string'
          }
          {
            name: 'AccountId'
            type: 'string'
          }
          {
            name: 'Region'
            type: 'string'
          }
          {
            name: 'Partition'
            type: 'string'
          }
          {
            name: 'Id'
            type: 'string'
          }
          {
            name: 'Arn'
            type: 'string'
          }
          {
            name: 'ActivityType'
            type: 'string'
          }
          {
            name: 'ResourceDetails'
            type: 'dynamic'
          }
          {
            name: 'ServiceDetails'
            type: 'dynamic'
          }
          {
            name: 'Severity'
            type: 'string'
          }
          {
            name: 'TimeCreated'
            type: 'string'
          }
          {
            name: 'Title'
            type: 'string'
          }
          {
            name: 'Description'
            type: 'string'
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
          name: 'Sentinel-AWSGuardDuty'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-AWSGuardDuty']
        destinations: ['Sentinel-AWSGuardDuty']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), SchemaVersion = tostring(SchemaVersion), AccountId = tostring(AccountId), Region = tostring(Region), Partition = tostring(Partition), Id = tostring(Id), Arn = tostring(Arn), ActivityType = tostring(ActivityType), ResourceDetails = todynamic(ResourceDetails), ServiceDetails = todynamic(ServiceDetails), Severity = toint(Severity), TimeCreated = todatetime(TimeCreated), Title = tostring(Title), Description = tostring(Description), SourceSystem = tostring(SourceSystem)'
        outputStream: 'Microsoft-AWSGuardDuty'
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
