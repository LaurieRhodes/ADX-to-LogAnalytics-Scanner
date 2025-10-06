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
// Data Collection Rule for ASimUserManagementActivityLogs
// ============================================================================
// Generated: 2025-09-18 07:50:11
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 111, DCR columns: 109 (Type column always filtered)
// Input stream: Custom-ASimUserManagementActivityLogs (always Custom- for JSON ingestion)
// Output stream: Microsoft-ASimUserManagementActivityLogs (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-ASimUserManagementActivityLogs'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-ASimUserManagementActivityLogs': {
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
            name: 'SrcGeoRegion'
            type: 'string'
          }
          {
            name: 'SrcGeoLongitude'
            type: 'string'
          }
          {
            name: 'SrcGeoLatitude'
            type: 'string'
          }
          {
            name: 'SrcGeoCountry'
            type: 'string'
          }
          {
            name: 'SrcDeviceType'
            type: 'string'
          }
          {
            name: 'SrcDvcScope'
            type: 'string'
          }
          {
            name: 'SrcDvcScopeId'
            type: 'string'
          }
          {
            name: 'SrcDvcIdType'
            type: 'string'
          }
          {
            name: 'SrcDvcId'
            type: 'string'
          }
          {
            name: 'SrcDescription'
            type: 'string'
          }
          {
            name: 'SrcFQDN'
            type: 'string'
          }
          {
            name: 'GroupOriginalType'
            type: 'string'
          }
          {
            name: 'GroupType'
            type: 'string'
          }
          {
            name: 'GroupNameType'
            type: 'string'
          }
          {
            name: 'GroupName'
            type: 'string'
          }
          {
            name: 'GroupIdType'
            type: 'string'
          }
          {
            name: 'GroupId'
            type: 'string'
          }
          {
            name: 'TargetOriginalUserType'
            type: 'string'
          }
          {
            name: 'TargetUserSessionId'
            type: 'string'
          }
          {
            name: 'TargetUserType'
            type: 'string'
          }
          {
            name: 'TargetUsernameType'
            type: 'string'
          }
          {
            name: 'TargetUsername'
            type: 'string'
          }
          {
            name: 'TargetUserScope'
            type: 'string'
          }
          {
            name: 'SrcGeoCity'
            type: 'string'
          }
          {
            name: 'TargetUserScopeId'
            type: 'string'
          }
          {
            name: 'SrcRiskLevel'
            type: 'string'
          }
          {
            name: 'ActingAppId'
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
            name: 'NewPropertyValue'
            type: 'string'
          }
          {
            name: 'PreviousPropertyValue'
            type: 'string'
          }
          {
            name: 'HttpUserAgent'
            type: 'string'
          }
          {
            name: 'ActingOriginalAppType'
            type: 'string'
          }
          {
            name: 'ActingAppType'
            type: 'string'
          }
          {
            name: 'ActingAppName'
            type: 'string'
          }
          {
            name: 'SrcOriginalRiskLevel'
            type: 'string'
          }
          {
            name: 'TargetUserIdType'
            type: 'string'
          }
          {
            name: 'TargetUserUid'
            type: 'string'
          }
          {
            name: 'TargetUserId'
            type: 'string'
          }
          {
            name: 'EventMessage'
            type: 'string'
          }
          {
            name: 'SrcDomainType'
            type: 'string'
          }
          {
            name: 'SrcDomain'
            type: 'string'
          }
          {
            name: 'SrcMacAddr'
            type: 'string'
          }
          {
            name: 'SrcHostname'
            type: 'string'
          }
          {
            name: 'SrcPortNumber'
            type: 'string'
          }
          {
            name: 'SrcIpAddr'
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
            name: 'DvcFQDN'
            type: 'string'
          }
          {
            name: 'DvcDomainType'
            type: 'string'
          }
          {
            name: 'DvcDomain'
            type: 'string'
          }
          {
            name: 'DvcHostname'
            type: 'string'
          }
          {
            name: 'DvcIpAddr'
            type: 'string'
          }
          {
            name: 'EventResultDetails'
            type: 'string'
          }
          {
            name: 'ActorUsernameType'
            type: 'string'
          }
          {
            name: 'ActorUsername'
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
            name: 'EventCount'
            type: 'string'
          }
          {
            name: 'EventSubType'
            type: 'string'
          }
          {
            name: 'EventOriginalUid'
            type: 'string'
          }
          {
            name: 'EventOriginalType'
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
            name: 'ActorScope'
            type: 'string'
          }
          {
            name: 'ActorScopeId'
            type: 'string'
          }
          {
            name: 'ActorUserIdType'
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
            name: 'ActorUserId'
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
            name: 'AdditionalFields'
            type: 'dynamic'
          }
          {
            name: 'DvcInterface'
            type: 'string'
          }
          {
            name: 'DvcOsVersion'
            type: 'string'
          }
          {
            name: 'DvcOs'
            type: 'string'
          }
          {
            name: 'DvcZone'
            type: 'string'
          }
          {
            name: 'DvcMacAddr'
            type: 'string'
          }
          {
            name: 'DvcDescription'
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
            name: 'DvcOriginalAction'
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
          name: 'Sentinel-ASimUserManagementActivityLogs'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-ASimUserManagementActivityLogs']
        destinations: ['Sentinel-ASimUserManagementActivityLogs']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), SrcGeoRegion = tostring(SrcGeoRegion), SrcGeoLongitude = toreal(SrcGeoLongitude), SrcGeoLatitude = toreal(SrcGeoLatitude), SrcGeoCountry = tostring(SrcGeoCountry), SrcDeviceType = tostring(SrcDeviceType), SrcDvcScope = tostring(SrcDvcScope), SrcDvcScopeId = tostring(SrcDvcScopeId), SrcDvcIdType = tostring(SrcDvcIdType), SrcDvcId = tostring(SrcDvcId), SrcDescription = tostring(SrcDescription), SrcFQDN = tostring(SrcFQDN), GroupOriginalType = tostring(GroupOriginalType), GroupType = tostring(GroupType), GroupNameType = tostring(GroupNameType), GroupName = tostring(GroupName), GroupIdType = tostring(GroupIdType), GroupId = tostring(GroupId), TargetOriginalUserType = tostring(TargetOriginalUserType), TargetUserSessionId = tostring(TargetUserSessionId), TargetUserType = tostring(TargetUserType), TargetUsernameType = tostring(TargetUsernameType), TargetUsername = tostring(TargetUsername), TargetUserScope = tostring(TargetUserScope), SrcGeoCity = tostring(SrcGeoCity), TargetUserScopeId = tostring(TargetUserScopeId), SrcRiskLevel = toint(SrcRiskLevel), ActingAppId = tostring(ActingAppId), EventEndTime = todatetime(EventEndTime), EventStartTime = todatetime(EventStartTime), EventSchemaVersion = tostring(EventSchemaVersion), EventSchema = tostring(EventSchema), ThreatLastReportedTime = todatetime(ThreatLastReportedTime), ThreatFirstReportedTime = todatetime(ThreatFirstReportedTime), ThreatIsActive = tobool(ThreatIsActive), ThreatOriginalConfidence = tostring(ThreatOriginalConfidence), ThreatConfidence = toint(ThreatConfidence), ThreatField = tostring(ThreatField), ThreatOriginalRiskLevel = tostring(ThreatOriginalRiskLevel), ThreatRiskLevel = toint(ThreatRiskLevel), ThreatCategory = tostring(ThreatCategory), ThreatName = tostring(ThreatName), ThreatId = tostring(ThreatId), RuleNumber = toint(RuleNumber), RuleName = tostring(RuleName), NewPropertyValue = tostring(NewPropertyValue), PreviousPropertyValue = tostring(PreviousPropertyValue), HttpUserAgent = tostring(HttpUserAgent), ActingOriginalAppType = tostring(ActingOriginalAppType), ActingAppType = tostring(ActingAppType), ActingAppName = tostring(ActingAppName), SrcOriginalRiskLevel = tostring(SrcOriginalRiskLevel), TargetUserIdType = tostring(TargetUserIdType), TargetUserUid = tostring(TargetUserUid), TargetUserId = tostring(TargetUserId), EventMessage = tostring(EventMessage), SrcDomainType = tostring(SrcDomainType), SrcDomain = tostring(SrcDomain), SrcMacAddr = tostring(SrcMacAddr), SrcHostname = tostring(SrcHostname), SrcPortNumber = toint(SrcPortNumber), SrcIpAddr = tostring(SrcIpAddr), DvcAction = tostring(DvcAction), DvcIdType = tostring(DvcIdType), DvcId = tostring(DvcId), DvcFQDN = tostring(DvcFQDN), DvcDomainType = tostring(DvcDomainType), DvcDomain = tostring(DvcDomain), DvcHostname = tostring(DvcHostname), DvcIpAddr = tostring(DvcIpAddr), EventResultDetails = tostring(EventResultDetails), ActorUsernameType = tostring(ActorUsernameType), ActorUsername = tostring(ActorUsername), EventType = tostring(EventType), EventSeverity = tostring(EventSeverity), EventResult = tostring(EventResult), EventVendor = tostring(EventVendor), EventProduct = tostring(EventProduct), EventCount = toint(EventCount), EventSubType = tostring(EventSubType), EventOriginalUid = tostring(EventOriginalUid), EventOriginalType = tostring(EventOriginalType), ActorSessionId = tostring(ActorSessionId), ActorOriginalUserType = tostring(ActorOriginalUserType), ActorUserType = tostring(ActorUserType), ActorScope = tostring(ActorScope), ActorScopeId = tostring(ActorScopeId), ActorUserIdType = tostring(ActorUserIdType), ActorUserSid = tostring(ActorUserSid), ActorUserAadId = tostring(ActorUserAadId), ActorUserId = tostring(ActorUserId), DvcScope = tostring(DvcScope), DvcScopeId = tostring(DvcScopeId), AdditionalFields = todynamic(AdditionalFields), DvcInterface = tostring(DvcInterface), DvcOsVersion = tostring(DvcOsVersion), DvcOs = tostring(DvcOs), DvcZone = tostring(DvcZone), DvcMacAddr = tostring(DvcMacAddr), DvcDescription = tostring(DvcDescription), EventReportUrl = tostring(EventReportUrl), EventOwner = tostring(EventOwner), EventProductVersion = tostring(EventProductVersion), EventOriginalSeverity = tostring(EventOriginalSeverity), EventOriginalResultDetails = tostring(EventOriginalResultDetails), EventOriginalSubType = tostring(EventOriginalSubType), DvcOriginalAction = tostring(DvcOriginalAction), SourceSystem = tostring(SourceSystem)'
        outputStream: 'Microsoft-ASimUserManagementActivityLogs'
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
