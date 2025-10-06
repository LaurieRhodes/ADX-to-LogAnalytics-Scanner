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
// Data Collection Rule for WindowsEvent
// ============================================================================
// Generated: 2025-09-18 07:50:29
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 26, DCR columns: 24 (Type column always filtered)
// Input stream: Custom-WindowsEvent (always Custom- for JSON ingestion)
// Output stream: Microsoft-WindowsEvent (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-WindowsEvent'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-WindowsEvent': {
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
            name: 'EventOriginId'
            type: 'string'
          }
          {
            name: 'EventID'
            type: 'string'
          }
          {
            name: 'RawEventData'
            type: 'string'
          }
          {
            name: 'EventData'
            type: 'dynamic'
          }
          {
            name: 'Data'
            type: 'dynamic'
          }
          {
            name: 'EventRecordId'
            type: 'string'
          }
          {
            name: 'SystemThreadId'
            type: 'string'
          }
          {
            name: 'SystemProcessId'
            type: 'string'
          }
          {
            name: 'Correlation'
            type: 'string'
          }
          {
            name: 'ManagementGroupName'
            type: 'string'
          }
          {
            name: 'Keywords'
            type: 'string'
          }
          {
            name: 'Version'
            type: 'string'
          }
          {
            name: 'SystemUserId'
            type: 'string'
          }
          {
            name: 'EventLevelName'
            type: 'string'
          }
          {
            name: 'EventLevel'
            type: 'string'
          }
          {
            name: 'Task'
            type: 'string'
          }
          {
            name: 'Computer'
            type: 'string'
          }
          {
            name: 'Channel'
            type: 'string'
          }
          {
            name: 'Provider'
            type: 'string'
          }
          {
            name: 'SourceSystem'
            type: 'string'
          }
          {
            name: 'Opcode'
            type: 'string'
          }
          {
            name: 'TimeCreated'
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
          name: 'Sentinel-WindowsEvent'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-WindowsEvent']
        destinations: ['Sentinel-WindowsEvent']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), EventOriginId = tostring(EventOriginId), EventID = toint(EventID), RawEventData = tostring(RawEventData), EventData = todynamic(EventData), Data = todynamic(Data), EventRecordId = tostring(EventRecordId), SystemThreadId = toint(SystemThreadId), SystemProcessId = toint(SystemProcessId), Correlation = tostring(Correlation), ManagementGroupName = tostring(ManagementGroupName), Keywords = tostring(Keywords), Version = toint(Version), SystemUserId = tostring(SystemUserId), EventLevelName = tostring(EventLevelName), EventLevel = toint(EventLevel), Task = toint(Task), Computer = tostring(Computer), Channel = tostring(Channel), Provider = tostring(Provider), SourceSystem = tostring(SourceSystem), Opcode = tostring(Opcode), TimeCreated = todatetime(TimeCreated)'
        outputStream: 'Microsoft-WindowsEvent'
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
