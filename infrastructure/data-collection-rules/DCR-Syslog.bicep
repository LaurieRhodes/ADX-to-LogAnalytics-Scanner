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
// Data Collection Rule for Syslog
// ============================================================================
// Generated: 2025-09-18 07:50:28
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 18, DCR columns: 16 (Type column always filtered)
// Input stream: Custom-Syslog (always Custom- for JSON ingestion)
// Output stream: Microsoft-Syslog (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-Syslog'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-Syslog': {
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
            name: 'SourceSystem'
            type: 'string'
          }
          {
            name: 'MG'
            type: 'string'
          }
          {
            name: 'TimeCollected'
            type: 'string'
          }
          {
            name: 'ManagementGroupName'
            type: 'string'
          }
          {
            name: 'Computer'
            type: 'string'
          }
          {
            name: 'EventTime'
            type: 'string'
          }
          {
            name: 'Facility'
            type: 'string'
          }
          {
            name: 'HostName'
            type: 'string'
          }
          {
            name: 'SeverityLevel'
            type: 'string'
          }
          {
            name: 'SyslogMessage'
            type: 'string'
          }
          {
            name: 'ProcessID'
            type: 'string'
          }
          {
            name: 'HostIP'
            type: 'string'
          }
          {
            name: 'ProcessName'
            type: 'string'
          }
          {
            name: 'CollectorHostName'
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
          name: 'Sentinel-Syslog'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-Syslog']
        destinations: ['Sentinel-Syslog']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), SourceSystem = tostring(SourceSystem), MG = toguid(MG), TimeCollected = todatetime(TimeCollected), ManagementGroupName = tostring(ManagementGroupName), Computer = tostring(Computer), EventTime = todatetime(EventTime), Facility = tostring(Facility), HostName = tostring(HostName), SeverityLevel = tostring(SeverityLevel), SyslogMessage = tostring(SyslogMessage), ProcessID = toint(ProcessID), HostIP = tostring(HostIP), ProcessName = tostring(ProcessName), CollectorHostName = tostring(CollectorHostName)'
        outputStream: 'Microsoft-Syslog'
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
