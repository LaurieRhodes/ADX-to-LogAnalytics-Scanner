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
// Data Collection Rule for ASimWebSessionLogs
// ============================================================================
// Generated: 2025-09-18 07:50:14
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 147, DCR columns: 145 (Type column always filtered)
// Input stream: Custom-ASimWebSessionLogs (always Custom- for JSON ingestion)
// Output stream: Microsoft-ASimWebSessionLogs (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-ASimWebSessionLogs'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-ASimWebSessionLogs': {
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
            name: 'SrcDeviceType'
            type: 'string'
          }
          {
            name: 'SrcGeoCountry'
            type: 'string'
          }
          {
            name: 'SrcGeoRegion'
            type: 'string'
          }
          {
            name: 'SrcGeoCity'
            type: 'string'
          }
          {
            name: 'SrcGeoLatitude'
            type: 'string'
          }
          {
            name: 'SrcGeoLongitude'
            type: 'string'
          }
          {
            name: 'SrcDvcIdType'
            type: 'string'
          }
          {
            name: 'SrcUserId'
            type: 'string'
          }
          {
            name: 'SrcUsername'
            type: 'string'
          }
          {
            name: 'SrcUsernameType'
            type: 'string'
          }
          {
            name: 'SrcUserType'
            type: 'string'
          }
          {
            name: 'SrcOriginalUserType'
            type: 'string'
          }
          {
            name: 'Url'
            type: 'string'
          }
          {
            name: 'UrlCategory'
            type: 'string'
          }
          {
            name: 'SrcUserIdType'
            type: 'string'
          }
          {
            name: 'UrlOriginal'
            type: 'string'
          }
          {
            name: 'SrcDvcId'
            type: 'string'
          }
          {
            name: 'SrcDomainType'
            type: 'string'
          }
          {
            name: 'ThreatIsActive'
            type: 'string'
          }
          {
            name: 'ThreatFirstReportedTime'
            type: 'string'
          }
          {
            name: 'ThreatLastReportedTime'
            type: 'string'
          }
          {
            name: 'DstNatIpAddr'
            type: 'string'
          }
          {
            name: 'DstNatPortNumber'
            type: 'string'
          }
          {
            name: 'SrcNatIpAddr'
            type: 'string'
          }
          {
            name: 'SrcFQDN'
            type: 'string'
          }
          {
            name: 'SrcNatPortNumber'
            type: 'string'
          }
          {
            name: 'SrcAppId'
            type: 'string'
          }
          {
            name: 'SrcAppType'
            type: 'string'
          }
          {
            name: 'SrcIpAddr'
            type: 'string'
          }
          {
            name: 'SrcPortNumber'
            type: 'string'
          }
          {
            name: 'SrcHostname'
            type: 'string'
          }
          {
            name: 'SrcDomain'
            type: 'string'
          }
          {
            name: 'SrcAppName'
            type: 'string'
          }
          {
            name: 'ThreatOriginalConfidence'
            type: 'string'
          }
          {
            name: 'HttpVersion'
            type: 'string'
          }
          {
            name: 'HttpContentType'
            type: 'string'
          }
          {
            name: 'ThreatCategory'
            type: 'string'
          }
          {
            name: 'ThreatRiskLevel'
            type: 'string'
          }
          {
            name: 'HttpHost'
            type: 'string'
          }
          {
            name: 'EventOwner'
            type: 'string'
          }
          {
            name: 'SrcProcessName'
            type: 'string'
          }
          {
            name: 'SrcProcessId'
            type: 'string'
          }
          {
            name: 'ThreatName'
            type: 'string'
          }
          {
            name: 'SrcProcessGuid'
            type: 'string'
          }
          {
            name: 'SrcUserScopeId'
            type: 'string'
          }
          {
            name: 'SrcDvcScopeId'
            type: 'string'
          }
          {
            name: 'SrcDvcScope'
            type: 'string'
          }
          {
            name: 'DstDvcScopeId'
            type: 'string'
          }
          {
            name: 'DstDvcScope'
            type: 'string'
          }
          {
            name: 'SrcMacAddr'
            type: 'string'
          }
          {
            name: 'SrcUserScope'
            type: 'string'
          }
          {
            name: 'HttpRequestMethod'
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
            name: 'HttpContentFormat'
            type: 'string'
          }
          {
            name: 'HttpReferrer'
            type: 'string'
          }
          {
            name: 'HttpUserAgent'
            type: 'string'
          }
          {
            name: 'HttpRequestXff'
            type: 'string'
          }
          {
            name: 'HttpRequestTime'
            type: 'string'
          }
          {
            name: 'HttpResponseTime'
            type: 'string'
          }
          {
            name: 'Rule'
            type: 'string'
          }
          {
            name: 'FileName'
            type: 'string'
          }
          {
            name: 'FileSHA1'
            type: 'string'
          }
          {
            name: 'FileSHA256'
            type: 'string'
          }
          {
            name: 'FileSHA512'
            type: 'string'
          }
          {
            name: 'FileSize'
            type: 'string'
          }
          {
            name: 'FileContentType'
            type: 'string'
          }
          {
            name: 'RuleName'
            type: 'string'
          }
          {
            name: 'FileMD5'
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
            name: 'ThreatIpAddr'
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
            name: 'EventOriginalSubType'
            type: 'string'
          }
          {
            name: 'EventOriginalResultDetails'
            type: 'string'
          }
          {
            name: 'EventSeverity'
            type: 'string'
          }
          {
            name: 'EventOriginalSeverity'
            type: 'string'
          }
          {
            name: 'EventResultDetails'
            type: 'string'
          }
          {
            name: 'EventProduct'
            type: 'string'
          }
          {
            name: 'EventVendor'
            type: 'string'
          }
          {
            name: 'EventSchemaVersion'
            type: 'string'
          }
          {
            name: 'EventReportUrl'
            type: 'string'
          }
          {
            name: 'AdditionalFields'
            type: 'dynamic'
          }
          {
            name: 'DstAppName'
            type: 'string'
          }
          {
            name: 'DstAppId'
            type: 'string'
          }
          {
            name: 'EventProductVersion'
            type: 'string'
          }
          {
            name: 'DstAppType'
            type: 'string'
          }
          {
            name: 'EventResult'
            type: 'string'
          }
          {
            name: 'EventType'
            type: 'string'
          }
          {
            name: 'Dvc'
            type: 'string'
          }
          {
            name: 'DvcIpAddr'
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
            name: 'DvcFQDN'
            type: 'string'
          }
          {
            name: 'EventSubType'
            type: 'string'
          }
          {
            name: 'DvcId'
            type: 'string'
          }
          {
            name: 'DvcAction'
            type: 'string'
          }
          {
            name: 'DvcOriginalAction'
            type: 'string'
          }
          {
            name: 'EventMessage'
            type: 'string'
          }
          {
            name: 'EventCount'
            type: 'string'
          }
          {
            name: 'EventStartTime'
            type: 'string'
          }
          {
            name: 'EventEndTime'
            type: 'string'
          }
          {
            name: 'DvcIdType'
            type: 'string'
          }
          {
            name: 'DstIpAddr'
            type: 'string'
          }
          {
            name: 'DstPortNumber'
            type: 'string'
          }
          {
            name: 'DstHostname'
            type: 'string'
          }
          {
            name: 'NetworkProtocolVersion'
            type: 'string'
          }
          {
            name: 'NetworkDirection'
            type: 'string'
          }
          {
            name: 'NetworkDuration'
            type: 'string'
          }
          {
            name: 'NetworkIcmpType'
            type: 'string'
          }
          {
            name: 'NetworkIcmpCode'
            type: 'string'
          }
          {
            name: 'NetworkConnectionHistory'
            type: 'string'
          }
          {
            name: 'NetworkProtocol'
            type: 'string'
          }
          {
            name: 'DstBytes'
            type: 'string'
          }
          {
            name: 'NetworkBytes'
            type: 'string'
          }
          {
            name: 'DstPackets'
            type: 'string'
          }
          {
            name: 'SrcPackets'
            type: 'string'
          }
          {
            name: 'NetworkPackets'
            type: 'string'
          }
          {
            name: 'NetworkSessionId'
            type: 'string'
          }
          {
            name: 'ThreatOriginalRiskLevel'
            type: 'string'
          }
          {
            name: 'SrcBytes'
            type: 'string'
          }
          {
            name: 'NetworkApplicationProtocol'
            type: 'string'
          }
          {
            name: 'DstOriginalUserType'
            type: 'string'
          }
          {
            name: 'DstUserType'
            type: 'string'
          }
          {
            name: 'DstDomain'
            type: 'string'
          }
          {
            name: 'DstDomainType'
            type: 'string'
          }
          {
            name: 'DstFQDN'
            type: 'string'
          }
          {
            name: 'DstDvcId'
            type: 'string'
          }
          {
            name: 'DstDvcIdType'
            type: 'string'
          }
          {
            name: 'DstDeviceType'
            type: 'string'
          }
          {
            name: 'DstGeoCountry'
            type: 'string'
          }
          {
            name: 'DstGeoRegion'
            type: 'string'
          }
          {
            name: 'DstGeoCity'
            type: 'string'
          }
          {
            name: 'DstGeoLatitude'
            type: 'string'
          }
          {
            name: 'DstGeoLongitude'
            type: 'string'
          }
          {
            name: 'DstUserId'
            type: 'string'
          }
          {
            name: 'DstUserIdType'
            type: 'string'
          }
          {
            name: 'DstUsername'
            type: 'string'
          }
          {
            name: 'DstUsernameType'
            type: 'string'
          }
          {
            name: 'DstMacAddr'
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
          name: 'Sentinel-ASimWebSessionLogs'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-ASimWebSessionLogs']
        destinations: ['Sentinel-ASimWebSessionLogs']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), SrcDeviceType = tostring(SrcDeviceType), SrcGeoCountry = tostring(SrcGeoCountry), SrcGeoRegion = tostring(SrcGeoRegion), SrcGeoCity = tostring(SrcGeoCity), SrcGeoLatitude = toreal(SrcGeoLatitude), SrcGeoLongitude = toreal(SrcGeoLongitude), SrcDvcIdType = tostring(SrcDvcIdType), SrcUserId = tostring(SrcUserId), SrcUsername = tostring(SrcUsername), SrcUsernameType = tostring(SrcUsernameType), SrcUserType = tostring(SrcUserType), SrcOriginalUserType = tostring(SrcOriginalUserType), Url = tostring(Url), UrlCategory = tostring(UrlCategory), SrcUserIdType = tostring(SrcUserIdType), UrlOriginal = tostring(UrlOriginal), SrcDvcId = tostring(SrcDvcId), SrcDomainType = tostring(SrcDomainType), ThreatIsActive = tobool(ThreatIsActive), ThreatFirstReportedTime = todatetime(ThreatFirstReportedTime), ThreatLastReportedTime = todatetime(ThreatLastReportedTime), DstNatIpAddr = tostring(DstNatIpAddr), DstNatPortNumber = toint(DstNatPortNumber), SrcNatIpAddr = tostring(SrcNatIpAddr), SrcFQDN = tostring(SrcFQDN), SrcNatPortNumber = toint(SrcNatPortNumber), SrcAppId = tostring(SrcAppId), SrcAppType = tostring(SrcAppType), SrcIpAddr = tostring(SrcIpAddr), SrcPortNumber = toint(SrcPortNumber), SrcHostname = tostring(SrcHostname), SrcDomain = tostring(SrcDomain), SrcAppName = tostring(SrcAppName), ThreatOriginalConfidence = tostring(ThreatOriginalConfidence), HttpVersion = tostring(HttpVersion), HttpContentType = tostring(HttpContentType), ThreatCategory = tostring(ThreatCategory), ThreatRiskLevel = toint(ThreatRiskLevel), HttpHost = tostring(HttpHost), EventOwner = tostring(EventOwner), SrcProcessName = tostring(SrcProcessName), SrcProcessId = tostring(SrcProcessId), ThreatName = tostring(ThreatName), SrcProcessGuid = tostring(SrcProcessGuid), SrcUserScopeId = tostring(SrcUserScopeId), SrcDvcScopeId = tostring(SrcDvcScopeId), SrcDvcScope = tostring(SrcDvcScope), DstDvcScopeId = tostring(DstDvcScopeId), DstDvcScope = tostring(DstDvcScope), SrcMacAddr = tostring(SrcMacAddr), SrcUserScope = tostring(SrcUserScope), HttpRequestMethod = tostring(HttpRequestMethod), ThreatId = tostring(ThreatId), RuleNumber = toint(RuleNumber), HttpContentFormat = tostring(HttpContentFormat), HttpReferrer = tostring(HttpReferrer), HttpUserAgent = tostring(HttpUserAgent), HttpRequestXff = tostring(HttpRequestXff), HttpRequestTime = toint(HttpRequestTime), HttpResponseTime = toint(HttpResponseTime), Rule = tostring(Rule), FileName = tostring(FileName), FileSHA1 = tostring(FileSHA1), FileSHA256 = tostring(FileSHA256), FileSHA512 = tostring(FileSHA512), FileSize = toint(FileSize), FileContentType = tostring(FileContentType), RuleName = tostring(RuleName), FileMD5 = tostring(FileMD5), ThreatConfidence = toint(ThreatConfidence), ThreatField = tostring(ThreatField), ThreatIpAddr = tostring(ThreatIpAddr), EventOriginalUid = tostring(EventOriginalUid), EventOriginalType = tostring(EventOriginalType), EventOriginalSubType = tostring(EventOriginalSubType), EventOriginalResultDetails = tostring(EventOriginalResultDetails), EventSeverity = tostring(EventSeverity), EventOriginalSeverity = tostring(EventOriginalSeverity), EventResultDetails = tostring(EventResultDetails), EventProduct = tostring(EventProduct), EventVendor = tostring(EventVendor), EventSchemaVersion = tostring(EventSchemaVersion), EventReportUrl = tostring(EventReportUrl), AdditionalFields = todynamic(AdditionalFields), DstAppName = tostring(DstAppName), DstAppId = tostring(DstAppId), EventProductVersion = tostring(EventProductVersion), DstAppType = tostring(DstAppType), EventResult = tostring(EventResult), EventType = tostring(EventType), Dvc = tostring(Dvc), DvcIpAddr = tostring(DvcIpAddr), DvcHostname = tostring(DvcHostname), DvcDomain = tostring(DvcDomain), DvcDomainType = tostring(DvcDomainType), DvcFQDN = tostring(DvcFQDN), EventSubType = tostring(EventSubType), DvcId = tostring(DvcId), DvcAction = tostring(DvcAction), DvcOriginalAction = tostring(DvcOriginalAction), EventMessage = tostring(EventMessage), EventCount = toint(EventCount), EventStartTime = todatetime(EventStartTime), EventEndTime = todatetime(EventEndTime), DvcIdType = tostring(DvcIdType), DstIpAddr = tostring(DstIpAddr), DstPortNumber = toint(DstPortNumber), DstHostname = tostring(DstHostname), NetworkProtocolVersion = tostring(NetworkProtocolVersion), NetworkDirection = tostring(NetworkDirection), NetworkDuration = toint(NetworkDuration), NetworkIcmpType = tostring(NetworkIcmpType), NetworkIcmpCode = toint(NetworkIcmpCode), NetworkConnectionHistory = tostring(NetworkConnectionHistory), NetworkProtocol = tostring(NetworkProtocol), DstBytes = tolong(DstBytes), NetworkBytes = tolong(NetworkBytes), DstPackets = tolong(DstPackets), SrcPackets = tolong(SrcPackets), NetworkPackets = tolong(NetworkPackets), NetworkSessionId = tostring(NetworkSessionId), ThreatOriginalRiskLevel = tostring(ThreatOriginalRiskLevel), SrcBytes = tolong(SrcBytes), NetworkApplicationProtocol = tostring(NetworkApplicationProtocol), DstOriginalUserType = tostring(DstOriginalUserType), DstUserType = tostring(DstUserType), DstDomain = tostring(DstDomain), DstDomainType = tostring(DstDomainType), DstFQDN = tostring(DstFQDN), DstDvcId = tostring(DstDvcId), DstDvcIdType = tostring(DstDvcIdType), DstDeviceType = tostring(DstDeviceType), DstGeoCountry = tostring(DstGeoCountry), DstGeoRegion = tostring(DstGeoRegion), DstGeoCity = tostring(DstGeoCity), DstGeoLatitude = toreal(DstGeoLatitude), DstGeoLongitude = toreal(DstGeoLongitude), DstUserId = tostring(DstUserId), DstUserIdType = tostring(DstUserIdType), DstUsername = tostring(DstUsername), DstUsernameType = tostring(DstUsernameType), DstMacAddr = tostring(DstMacAddr), SourceSystem = tostring(SourceSystem)'
        outputStream: 'Microsoft-ASimWebSessionLogs'
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
