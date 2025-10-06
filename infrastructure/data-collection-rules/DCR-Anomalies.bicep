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
// Data Collection Rule for Anomalies
// ============================================================================
// Generated: 2025-09-18 07:49:56
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 36, DCR columns: 35 (Type column always filtered)
// Input stream: Custom-Anomalies (always Custom- for JSON ingestion)
// Output stream: Microsoft-Anomalies (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-Anomalies'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-Anomalies': {
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
            name: 'ExtendedProperties'
            type: 'dynamic'
          }
          {
            name: 'Entities'
            type: 'dynamic'
          }
          {
            name: 'AnomalyReasons'
            type: 'dynamic'
          }
          {
            name: 'UserInsights'
            type: 'dynamic'
          }
          {
            name: 'DeviceInsights'
            type: 'dynamic'
          }
          {
            name: 'ActivityInsights'
            type: 'dynamic'
          }
          {
            name: 'DestinationDevice'
            type: 'string'
          }
          {
            name: 'DestinationLocation'
            type: 'dynamic'
          }
          {
            name: 'DestinationIpAddress'
            type: 'string'
          }
          {
            name: 'SourceDevice'
            type: 'string'
          }
          {
            name: 'SourceLocation'
            type: 'dynamic'
          }
          {
            name: 'SourceIpAddress'
            type: 'string'
          }
          {
            name: 'UserPrincipalName'
            type: 'string'
          }
          {
            name: 'UserName'
            type: 'string'
          }
          {
            name: 'Techniques'
            type: 'string'
          }
          {
            name: 'Tactics'
            type: 'string'
          }
          {
            name: 'ExtendedLinks'
            type: 'dynamic'
          }
          {
            name: 'Id'
            type: 'string'
          }
          {
            name: 'WorkspaceId'
            type: 'string'
          }
          {
            name: 'VendorName'
            type: 'string'
          }
          {
            name: 'AnomalyTemplateId'
            type: 'string'
          }
          {
            name: 'AnomalyTemplateName'
            type: 'string'
          }
          {
            name: 'AnomalyTemplateVersion'
            type: 'string'
          }
          {
            name: 'AnomalyDetails'
            type: 'dynamic'
          }
          {
            name: 'RuleId'
            type: 'string'
          }
          {
            name: 'RuleName'
            type: 'string'
          }
          {
            name: 'RuleConfigVersion'
            type: 'string'
          }
          {
            name: 'Score'
            type: 'string'
          }
          {
            name: 'Description'
            type: 'string'
          }
          {
            name: 'StartTime'
            type: 'string'
          }
          {
            name: 'EndTime'
            type: 'string'
          }
          {
            name: 'RuleStatus'
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
          name: 'Sentinel-Anomalies'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-Anomalies']
        destinations: ['Sentinel-Anomalies']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), ExtendedProperties = todynamic(ExtendedProperties), Entities = todynamic(Entities), AnomalyReasons = todynamic(AnomalyReasons), UserInsights = todynamic(UserInsights), DeviceInsights = todynamic(DeviceInsights), ActivityInsights = todynamic(ActivityInsights), DestinationDevice = tostring(DestinationDevice), DestinationLocation = todynamic(DestinationLocation), DestinationIpAddress = tostring(DestinationIpAddress), SourceDevice = tostring(SourceDevice), SourceLocation = todynamic(SourceLocation), SourceIpAddress = tostring(SourceIpAddress), UserPrincipalName = tostring(UserPrincipalName), UserName = tostring(UserName), Techniques = tostring(Techniques), Tactics = tostring(Tactics), ExtendedLinks = todynamic(ExtendedLinks), Id = tostring(Id), WorkspaceId = tostring(WorkspaceId), VendorName = tostring(VendorName), AnomalyTemplateId = tostring(AnomalyTemplateId), AnomalyTemplateName = tostring(AnomalyTemplateName), AnomalyTemplateVersion = tostring(AnomalyTemplateVersion), AnomalyDetails = todynamic(AnomalyDetails), RuleId = tostring(RuleId), RuleName = tostring(RuleName), RuleConfigVersion = tostring(RuleConfigVersion), Score = toreal(Score), Description = tostring(Description), StartTime = todatetime(StartTime), EndTime = todatetime(EndTime), RuleStatus = tostring(RuleStatus), SourceSystem = tostring(SourceSystem)'
        outputStream: 'Microsoft-Anomalies'
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
