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
// Data Collection Rule for ASimRegistryEventLogs
// ============================================================================
// Generated: 2025-09-18 07:50:10
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 84, DCR columns: 82 (Type column always filtered)
// Input stream: Custom-ASimRegistryEventLogs (always Custom- for JSON ingestion)
// Output stream: Microsoft-ASimRegistryEventLogs (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-ASimRegistryEventLogs'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-ASimRegistryEventLogs': {
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
            name: 'ActingProcessGuid'
            type: 'string'
          }
          {
            name: 'ActingProcessCommandLine'
            type: 'string'
          }
          {
            name: 'ActingProcessId'
            type: 'string'
          }
          {
            name: 'ActingProcessName'
            type: 'string'
          }
          {
            name: 'ActorSessionId'
            type: 'string'
          }
          {
            name: 'ActorOriginalUserType'
            type: 'string'
          }
          {
            name: 'ActorUserType'
            type: 'string'
          }
          {
            name: 'ParentProcessName'
            type: 'string'
          }
          {
            name: 'ActorUsernameType'
            type: 'string'
          }
          {
            name: 'ActorScope'
            type: 'string'
          }
          {
            name: 'ActorScopeId'
            type: 'string'
          }
          {
            name: 'ActorUserSid'
            type: 'string'
          }
          {
            name: 'ActorUserAadId'
            type: 'string'
          }
          {
            name: 'DvcScope'
            type: 'string'
          }
          {
            name: 'DvcScopeId'
            type: 'string'
          }
          {
            name: 'DvcInterface'
            type: 'string'
          }
          {
            name: 'ActorUsername'
            type: 'string'
          }
          {
            name: 'ParentProcessId'
            type: 'string'
          }
          {
            name: 'ParentProcessCommandLine'
            type: 'string'
          }
          {
            name: 'ParentProcessGuid'
            type: 'string'
          }
          {
            name: 'EventEndTime'
            type: 'string'
          }
          {
            name: 'EventStartTime'
            type: 'string'
          }
          {
            name: 'EventSchemaVersion'
            type: 'string'
          }
          {
            name: 'EventSchema'
            type: 'string'
          }
          {
            name: 'ThreatLastReportedTime'
            type: 'string'
          }
          {
            name: 'ThreatFirstReportedTime'
            type: 'string'
          }
          {
            name: 'ThreatIsActive'
            type: 'string'
          }
          {
            name: 'ThreatOriginalConfidence'
            type: 'string'
          }
          {
            name: 'ThreatConfidence'
            type: 'string'
          }
          {
            name: 'ThreatField'
            type: 'string'
          }
          {
            name: 'ThreatOriginalRiskLevel'
            type: 'string'
          }
          {
            name: 'ThreatRiskLevel'
            type: 'string'
          }
          {
            name: 'ThreatCategory'
            type: 'string'
          }
          {
            name: 'ThreatName'
            type: 'string'
          }
          {
            name: 'ThreatId'
            type: 'string'
          }
          {
            name: 'RuleNumber'
            type: 'string'
          }
          {
            name: 'RuleName'
            type: 'string'
          }
          {
            name: 'DvcOriginalAction'
            type: 'string'
          }
          {
            name: 'AdditionalFields'
            type: 'dynamic'
          }
          {
            name: 'DvcOsVersion'
            type: 'string'
          }
          {
            name: 'DvcZone'
            type: 'string'
          }
          {
            name: 'EventResultDetails'
            type: 'string'
          }
          {
            name: 'ActorUserIdType'
            type: 'string'
          }
          {
            name: 'ActorUserId'
            type: 'string'
          }
          {
            name: 'RegistryPreviousValueData'
            type: 'string'
          }
          {
            name: 'RegistryPreviousValueType'
            type: 'string'
          }
          {
            name: 'RegistryPreviousValue'
            type: 'string'
          }
          {
            name: 'RegistryPreviousKey'
            type: 'string'
          }
          {
            name: 'DvcIpAddr'
            type: 'string'
          }
          {
            name: 'RegistryValueData'
            type: 'string'
          }
          {
            name: 'RegistryValue'
            type: 'string'
          }
          {
            name: 'RegistryKey'
            type: 'string'
          }
          {
            name: 'EventType'
            type: 'string'
          }
          {
            name: 'EventSeverity'
            type: 'string'
          }
          {
            name: 'EventResult'
            type: 'string'
          }
          {
            name: 'EventVendor'
            type: 'string'
          }
          {
            name: 'EventProduct'
            type: 'string'
          }
          {
            name: 'RegistryValueType'
            type: 'string'
          }
          {
            name: 'DvcHostname'
            type: 'string'
          }
          {
            name: 'DvcDomain'
            type: 'string'
          }
          {
            name: 'DvcDomainType'
            type: 'string'
          }
          {
            name: 'DvcMacAddr'
            type: 'string'
          }
          {
            name: 'EventReportUrl'
            type: 'string'
          }
          {
            name: 'EventOwner'
            type: 'string'
          }
          {
            name: 'EventProductVersion'
            type: 'string'
          }
          {
            name: 'EventOriginalSeverity'
            type: 'string'
          }
          {
            name: 'EventOriginalResultDetails'
            type: 'string'
          }
          {
            name: 'EventOriginalSubType'
            type: 'string'
          }
          {
            name: 'EventOriginalType'
            type: 'string'
          }
          {
            name: 'EventOriginalUid'
            type: 'string'
          }
          {
            name: 'EventSubType'
            type: 'string'
          }
          {
            name: 'EventCount'
            type: 'string'
          }
          {
            name: 'EventMessage'
            type: 'string'
          }
          {
            name: 'DvcAction'
            type: 'string'
          }
          {
            name: 'DvcIdType'
            type: 'string'
          }
          {
            name: 'DvcId'
            type: 'string'
          }
          {
            name: 'DvcDescription'
            type: 'string'
          }
          {
            name: 'DvcFQDN'
            type: 'string'
          }
          {
            name: 'DvcOs'
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
          name: 'Sentinel-ASimRegistryEventLogs'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-ASimRegistryEventLogs']
        destinations: ['Sentinel-ASimRegistryEventLogs']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), ActingProcessGuid = tostring(ActingProcessGuid), ActingProcessCommandLine = tostring(ActingProcessCommandLine), ActingProcessId = tostring(ActingProcessId), ActingProcessName = tostring(ActingProcessName), ActorSessionId = tostring(ActorSessionId), ActorOriginalUserType = tostring(ActorOriginalUserType), ActorUserType = tostring(ActorUserType), ParentProcessName = tostring(ParentProcessName), ActorUsernameType = tostring(ActorUsernameType), ActorScope = tostring(ActorScope), ActorScopeId = tostring(ActorScopeId), ActorUserSid = tostring(ActorUserSid), ActorUserAadId = tostring(ActorUserAadId), DvcScope = tostring(DvcScope), DvcScopeId = tostring(DvcScopeId), DvcInterface = tostring(DvcInterface), ActorUsername = tostring(ActorUsername), ParentProcessId = tostring(ParentProcessId), ParentProcessCommandLine = tostring(ParentProcessCommandLine), ParentProcessGuid = tostring(ParentProcessGuid), EventEndTime = todatetime(EventEndTime), EventStartTime = todatetime(EventStartTime), EventSchemaVersion = tostring(EventSchemaVersion), EventSchema = tostring(EventSchema), ThreatLastReportedTime = todatetime(ThreatLastReportedTime), ThreatFirstReportedTime = todatetime(ThreatFirstReportedTime), ThreatIsActive = tobool(ThreatIsActive), ThreatOriginalConfidence = tostring(ThreatOriginalConfidence), ThreatConfidence = toint(ThreatConfidence), ThreatField = tostring(ThreatField), ThreatOriginalRiskLevel = tostring(ThreatOriginalRiskLevel), ThreatRiskLevel = toint(ThreatRiskLevel), ThreatCategory = tostring(ThreatCategory), ThreatName = tostring(ThreatName), ThreatId = tostring(ThreatId), RuleNumber = toint(RuleNumber), RuleName = tostring(RuleName), DvcOriginalAction = tostring(DvcOriginalAction), AdditionalFields = todynamic(AdditionalFields), DvcOsVersion = tostring(DvcOsVersion), DvcZone = tostring(DvcZone), EventResultDetails = tostring(EventResultDetails), ActorUserIdType = tostring(ActorUserIdType), ActorUserId = tostring(ActorUserId), RegistryPreviousValueData = tostring(RegistryPreviousValueData), RegistryPreviousValueType = tostring(RegistryPreviousValueType), RegistryPreviousValue = tostring(RegistryPreviousValue), RegistryPreviousKey = tostring(RegistryPreviousKey), DvcIpAddr = tostring(DvcIpAddr), RegistryValueData = tostring(RegistryValueData), RegistryValue = tostring(RegistryValue), RegistryKey = tostring(RegistryKey), EventType = tostring(EventType), EventSeverity = tostring(EventSeverity), EventResult = tostring(EventResult), EventVendor = tostring(EventVendor), EventProduct = tostring(EventProduct), RegistryValueType = tostring(RegistryValueType), DvcHostname = tostring(DvcHostname), DvcDomain = tostring(DvcDomain), DvcDomainType = tostring(DvcDomainType), DvcMacAddr = tostring(DvcMacAddr), EventReportUrl = tostring(EventReportUrl), EventOwner = tostring(EventOwner), EventProductVersion = tostring(EventProductVersion), EventOriginalSeverity = tostring(EventOriginalSeverity), EventOriginalResultDetails = tostring(EventOriginalResultDetails), EventOriginalSubType = tostring(EventOriginalSubType), EventOriginalType = tostring(EventOriginalType), EventOriginalUid = tostring(EventOriginalUid), EventSubType = tostring(EventSubType), EventCount = toint(EventCount), EventMessage = tostring(EventMessage), DvcAction = tostring(DvcAction), DvcIdType = tostring(DvcIdType), DvcId = tostring(DvcId), DvcDescription = tostring(DvcDescription), DvcFQDN = tostring(DvcFQDN), DvcOs = tostring(DvcOs), SourceSystem = tostring(SourceSystem)'
        outputStream: 'Microsoft-ASimRegistryEventLogs'
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
