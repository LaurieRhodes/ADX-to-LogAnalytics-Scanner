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
// Data Collection Rule for ASimAuthenticationEventLogs
// ============================================================================
// Generated: 2025-09-18 07:49:59
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 128, DCR columns: 126 (Type column always filtered)
// Input stream: Custom-ASimAuthenticationEventLogs (always Custom- for JSON ingestion)
// Output stream: Microsoft-ASimAuthenticationEventLogs (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-ASimAuthenticationEventLogs'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-ASimAuthenticationEventLogs': {
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
            name: 'SrcDomainType'
            type: 'string'
          }
          {
            name: 'SrcDomain'
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
            name: 'TargetUrl'
            type: 'string'
          }
          {
            name: 'TargetOriginalAppType'
            type: 'string'
          }
          {
            name: 'TargetAppType'
            type: 'string'
          }
          {
            name: 'TargetAppName'
            type: 'string'
          }
          {
            name: 'TargetAppId'
            type: 'string'
          }
          {
            name: 'TargetSessionId'
            type: 'string'
          }
          {
            name: 'TargetOriginalUserType'
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
            name: 'TargetUserScopeId'
            type: 'string'
          }
          {
            name: 'TargetUserIdType'
            type: 'string'
          }
          {
            name: 'TargetUserId'
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
            name: 'SrcDvcScope'
            type: 'string'
          }
          {
            name: 'SrcDeviceType'
            type: 'string'
          }
          {
            name: 'SrcGeoCountry'
            type: 'string'
          }
          {
            name: 'SrcGeoLatitude'
            type: 'string'
          }
          {
            name: 'LogonMethod'
            type: 'string'
          }
          {
            name: 'TargetDvcOs'
            type: 'string'
          }
          {
            name: 'TargetOriginalRiskLevel'
            type: 'string'
          }
          {
            name: 'TargetRiskLevel'
            type: 'string'
          }
          {
            name: 'TargetGeoCity'
            type: 'string'
          }
          {
            name: 'TargetGeoRegion'
            type: 'string'
          }
          {
            name: 'TargetGeoLongitude'
            type: 'string'
          }
          {
            name: 'TargetGeoLatitude'
            type: 'string'
          }
          {
            name: 'TargetGeoCountry'
            type: 'string'
          }
          {
            name: 'TargetDeviceType'
            type: 'string'
          }
          {
            name: 'TargetDvcScope'
            type: 'string'
          }
          {
            name: 'TargetDvcScopeId'
            type: 'string'
          }
          {
            name: 'TargetDvcIdType'
            type: 'string'
          }
          {
            name: 'ActingAppName'
            type: 'string'
          }
          {
            name: 'TargetDvcId'
            type: 'string'
          }
          {
            name: 'TargetFQDN'
            type: 'string'
          }
          {
            name: 'TargetDomainType'
            type: 'string'
          }
          {
            name: 'TargetDomain'
            type: 'string'
          }
          {
            name: 'TargetHostname'
            type: 'string'
          }
          {
            name: 'TargetPortNumber'
            type: 'string'
          }
          {
            name: 'TargetIpAddr'
            type: 'string'
          }
          {
            name: 'SrcDvcOs'
            type: 'string'
          }
          {
            name: 'SrcIsp'
            type: 'string'
          }
          {
            name: 'SrcOriginalRiskLevel'
            type: 'string'
          }
          {
            name: 'SrcRiskLevel'
            type: 'string'
          }
          {
            name: 'SrcGeoCity'
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
            name: 'TargetDescription'
            type: 'string'
          }
          {
            name: 'LogonProtocol'
            type: 'string'
          }
          {
            name: 'ActingAppId'
            type: 'string'
          }
          {
            name: 'ActorOriginalUserType'
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
            name: 'EventReportUrl'
            type: 'string'
          }
          {
            name: 'EventOwner'
            type: 'string'
          }
          {
            name: 'EventSchemaVersion'
            type: 'string'
          }
          {
            name: 'EventVendor'
            type: 'string'
          }
          {
            name: 'EventProductVersion'
            type: 'string'
          }
          {
            name: 'EventProduct'
            type: 'string'
          }
          {
            name: 'EventOriginalSeverity'
            type: 'string'
          }
          {
            name: 'EventSeverity'
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
            name: 'EventResultDetails'
            type: 'string'
          }
          {
            name: 'EventResult'
            type: 'string'
          }
          {
            name: 'EventSubType'
            type: 'string'
          }
          {
            name: 'EventType'
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
            name: 'EventCount'
            type: 'string'
          }
          {
            name: 'EventMessage'
            type: 'string'
          }
          {
            name: 'AdditionalFields'
            type: 'dynamic'
          }
          {
            name: 'ThreatOriginalRiskLevel'
            type: 'string'
          }
          {
            name: 'ThreatConfidence'
            type: 'string'
          }
          {
            name: 'ThreatOriginalConfidence'
            type: 'string'
          }
          {
            name: 'ThreatIsActive'
            type: 'string'
          }
          {
            name: 'ActorUserType'
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
            name: 'DvcInterface'
            type: 'string'
          }
          {
            name: 'DvcOriginalAction'
            type: 'string'
          }
          {
            name: 'DvcAction'
            type: 'string'
          }
          {
            name: 'DvcOsVersion'
            type: 'string'
          }
          {
            name: 'ActorSessionId'
            type: 'string'
          }
          {
            name: 'DvcOs'
            type: 'string'
          }
          {
            name: 'DvcMacAddr'
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
            name: 'ThreatIpAddr'
            type: 'string'
          }
          {
            name: 'ThreatField'
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
            name: 'DvcZone'
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
          name: 'Sentinel-ASimAuthenticationEventLogs'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-ASimAuthenticationEventLogs']
        destinations: ['Sentinel-ASimAuthenticationEventLogs']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), SrcDvcScopeId = tostring(SrcDvcScopeId), SrcDvcIdType = tostring(SrcDvcIdType), SrcDvcId = tostring(SrcDvcId), SrcDescription = tostring(SrcDescription), SrcFQDN = tostring(SrcFQDN), SrcDomainType = tostring(SrcDomainType), SrcDomain = tostring(SrcDomain), SrcHostname = tostring(SrcHostname), SrcPortNumber = toint(SrcPortNumber), SrcIpAddr = tostring(SrcIpAddr), TargetUrl = tostring(TargetUrl), TargetOriginalAppType = tostring(TargetOriginalAppType), TargetAppType = tostring(TargetAppType), TargetAppName = tostring(TargetAppName), TargetAppId = tostring(TargetAppId), TargetSessionId = tostring(TargetSessionId), TargetOriginalUserType = tostring(TargetOriginalUserType), TargetUserType = tostring(TargetUserType), TargetUsernameType = tostring(TargetUsernameType), TargetUsername = tostring(TargetUsername), TargetUserScope = tostring(TargetUserScope), TargetUserScopeId = tostring(TargetUserScopeId), TargetUserIdType = tostring(TargetUserIdType), TargetUserId = tostring(TargetUserId), HttpUserAgent = tostring(HttpUserAgent), ActingOriginalAppType = tostring(ActingOriginalAppType), ActingAppType = tostring(ActingAppType), SrcDvcScope = tostring(SrcDvcScope), SrcDeviceType = tostring(SrcDeviceType), SrcGeoCountry = tostring(SrcGeoCountry), SrcGeoLatitude = toreal(SrcGeoLatitude), LogonMethod = tostring(LogonMethod), TargetDvcOs = tostring(TargetDvcOs), TargetOriginalRiskLevel = tostring(TargetOriginalRiskLevel), TargetRiskLevel = toint(TargetRiskLevel), TargetGeoCity = tostring(TargetGeoCity), TargetGeoRegion = tostring(TargetGeoRegion), TargetGeoLongitude = toreal(TargetGeoLongitude), TargetGeoLatitude = toreal(TargetGeoLatitude), TargetGeoCountry = tostring(TargetGeoCountry), TargetDeviceType = tostring(TargetDeviceType), TargetDvcScope = tostring(TargetDvcScope), TargetDvcScopeId = tostring(TargetDvcScopeId), TargetDvcIdType = tostring(TargetDvcIdType), ActingAppName = tostring(ActingAppName), TargetDvcId = tostring(TargetDvcId), TargetFQDN = tostring(TargetFQDN), TargetDomainType = tostring(TargetDomainType), TargetDomain = tostring(TargetDomain), TargetHostname = tostring(TargetHostname), TargetPortNumber = toint(TargetPortNumber), TargetIpAddr = tostring(TargetIpAddr), SrcDvcOs = tostring(SrcDvcOs), SrcIsp = tostring(SrcIsp), SrcOriginalRiskLevel = tostring(SrcOriginalRiskLevel), SrcRiskLevel = toint(SrcRiskLevel), SrcGeoCity = tostring(SrcGeoCity), SrcGeoRegion = tostring(SrcGeoRegion), SrcGeoLongitude = toreal(SrcGeoLongitude), TargetDescription = tostring(TargetDescription), LogonProtocol = tostring(LogonProtocol), ActingAppId = tostring(ActingAppId), ActorOriginalUserType = tostring(ActorOriginalUserType), ThreatRiskLevel = toint(ThreatRiskLevel), ThreatCategory = tostring(ThreatCategory), ThreatName = tostring(ThreatName), ThreatId = tostring(ThreatId), RuleNumber = toint(RuleNumber), RuleName = tostring(RuleName), EventReportUrl = tostring(EventReportUrl), EventOwner = tostring(EventOwner), EventSchemaVersion = tostring(EventSchemaVersion), EventVendor = tostring(EventVendor), EventProductVersion = tostring(EventProductVersion), EventProduct = tostring(EventProduct), EventOriginalSeverity = tostring(EventOriginalSeverity), EventSeverity = tostring(EventSeverity), EventOriginalResultDetails = tostring(EventOriginalResultDetails), EventOriginalSubType = tostring(EventOriginalSubType), EventOriginalType = tostring(EventOriginalType), EventOriginalUid = tostring(EventOriginalUid), EventResultDetails = tostring(EventResultDetails), EventResult = tostring(EventResult), EventSubType = tostring(EventSubType), EventType = tostring(EventType), EventEndTime = todatetime(EventEndTime), EventStartTime = todatetime(EventStartTime), EventCount = toint(EventCount), EventMessage = tostring(EventMessage), AdditionalFields = todynamic(AdditionalFields), ThreatOriginalRiskLevel = tostring(ThreatOriginalRiskLevel), ThreatConfidence = toint(ThreatConfidence), ThreatOriginalConfidence = tostring(ThreatOriginalConfidence), ThreatIsActive = tobool(ThreatIsActive), ActorUserType = tostring(ActorUserType), ActorUsernameType = tostring(ActorUsernameType), ActorUsername = tostring(ActorUsername), ActorScope = tostring(ActorScope), ActorScopeId = tostring(ActorScopeId), ActorUserIdType = tostring(ActorUserIdType), ActorUserId = tostring(ActorUserId), DvcScope = tostring(DvcScope), DvcScopeId = tostring(DvcScopeId), DvcInterface = tostring(DvcInterface), DvcOriginalAction = tostring(DvcOriginalAction), DvcAction = tostring(DvcAction), DvcOsVersion = tostring(DvcOsVersion), ActorSessionId = tostring(ActorSessionId), DvcOs = tostring(DvcOs), DvcMacAddr = tostring(DvcMacAddr), DvcIdType = tostring(DvcIdType), DvcId = tostring(DvcId), DvcDescription = tostring(DvcDescription), DvcFQDN = tostring(DvcFQDN), DvcDomainType = tostring(DvcDomainType), DvcDomain = tostring(DvcDomain), DvcHostname = tostring(DvcHostname), DvcIpAddr = tostring(DvcIpAddr), ThreatIpAddr = tostring(ThreatIpAddr), ThreatField = tostring(ThreatField), ThreatLastReportedTime = todatetime(ThreatLastReportedTime), ThreatFirstReportedTime = todatetime(ThreatFirstReportedTime), DvcZone = tostring(DvcZone), SourceSystem = tostring(SourceSystem)'
        outputStream: 'Microsoft-ASimAuthenticationEventLogs'
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
