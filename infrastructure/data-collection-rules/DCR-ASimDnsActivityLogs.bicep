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
// Data Collection Rule for ASimDnsActivityLogs
// ============================================================================
// Generated: 2025-09-18 07:50:02
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 137, DCR columns: 135 (Type column always filtered)
// Input stream: Custom-ASimDnsActivityLogs (always Custom- for JSON ingestion)
// Output stream: Microsoft-ASimDnsActivityLogs (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-ASimDnsActivityLogs'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-ASimDnsActivityLogs': {
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
            name: 'EventProductVersion'
            type: 'string'
          }
          {
            name: 'EventOwner'
            type: 'string'
          }
          {
            name: 'DnsResponseIpRegion'
            type: 'string'
          }
          {
            name: 'DnsResponseIpCity'
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
            name: 'Dvc'
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
            name: 'EventOriginalUid'
            type: 'string'
          }
          {
            name: 'EventMessage'
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
            name: 'ThreatLastReportedTime_d'
            type: 'string'
          }
          {
            name: 'ThreatLastReportedTime'
            type: 'string'
          }
          {
            name: 'ThreatFirstReportedTime_d'
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
            name: 'ThreatOriginalRiskLevel'
            type: 'string'
          }
          {
            name: 'ThreatOriginalRiskLevel_s'
            type: 'string'
          }
          {
            name: 'ThreatRiskLevel'
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
            name: 'ThreatName'
            type: 'string'
          }
          {
            name: 'ThreatCategory'
            type: 'string'
          }
          {
            name: 'UrlCategory'
            type: 'string'
          }
          {
            name: 'EventSeverity'
            type: 'string'
          }
          {
            name: 'Src'
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
            name: 'DnsFlagsTruncated'
            type: 'string'
          }
          {
            name: 'DnsFlagsRecursionAvailable'
            type: 'string'
          }
          {
            name: 'DnsFlagsCheckingDisabled'
            type: 'string'
          }
          {
            name: 'DnsFlags'
            type: 'string'
          }
          {
            name: 'DvcAction'
            type: 'string'
          }
          {
            name: 'DstDeviceType'
            type: 'string'
          }
          {
            name: 'DstDvcIdType'
            type: 'string'
          }
          {
            name: 'DstDvcScopeId'
            type: 'string'
          }
          {
            name: 'DstDvcId'
            type: 'string'
          }
          {
            name: 'DstFQDN'
            type: 'string'
          }
          {
            name: 'DstDomainType'
            type: 'string'
          }
          {
            name: 'DstDomain'
            type: 'string'
          }
          {
            name: 'DstHostname'
            type: 'string'
          }
          {
            name: 'DstPortNumber'
            type: 'string'
          }
          {
            name: 'ThreatField'
            type: 'string'
          }
          {
            name: 'Dst'
            type: 'string'
          }
          {
            name: 'SrcProcessId'
            type: 'string'
          }
          {
            name: 'SrcProcessName'
            type: 'string'
          }
          {
            name: 'SrcOriginalUserType'
            type: 'string'
          }
          {
            name: 'SrcUserType'
            type: 'string'
          }
          {
            name: 'SrcUsernameType'
            type: 'string'
          }
          {
            name: 'SrcUsername'
            type: 'string'
          }
          {
            name: 'SrcUserIdType'
            type: 'string'
          }
          {
            name: 'SrcUserId'
            type: 'string'
          }
          {
            name: 'SrcRiskLevel'
            type: 'string'
          }
          {
            name: 'SrcDeviceType'
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
            name: 'SrcFQDN'
            type: 'string'
          }
          {
            name: 'SrcDomainType'
            type: 'string'
          }
          {
            name: 'SrcProcessGuid'
            type: 'string'
          }
          {
            name: 'ThreatIpAddr'
            type: 'string'
          }
          {
            name: 'ThreatId'
            type: 'string'
          }
          {
            name: 'SrcUserSessionId'
            type: 'string'
          }
          {
            name: 'DnsQueryType'
            type: 'string'
          }
          {
            name: 'DnsQuery'
            type: 'string'
          }
          {
            name: 'DstGeoLongitude'
            type: 'string'
          }
          {
            name: 'DstGeoLatitude'
            type: 'string'
          }
          {
            name: 'DstGeoCity'
            type: 'string'
          }
          {
            name: 'DstGeoRegion'
            type: 'string'
          }
          {
            name: 'DstGeoCountry'
            type: 'string'
          }
          {
            name: 'DstIpAddr'
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
            name: 'SrcGeoCity'
            type: 'string'
          }
          {
            name: 'SrcGeoRegion'
            type: 'string'
          }
          {
            name: 'SrcGeoCountry'
            type: 'string'
          }
          {
            name: 'SrcPortNumber'
            type: 'string'
          }
          {
            name: 'DnsQueryTypeName'
            type: 'string'
          }
          {
            name: 'SrcIpAddr'
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
            name: 'EventVendor'
            type: 'string'
          }
          {
            name: 'EventProduct'
            type: 'string'
          }
          {
            name: 'EventOriginalType'
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
            name: 'EventCount'
            type: 'string'
          }
          {
            name: 'AdditionalFields'
            type: 'dynamic'
          }
          {
            name: 'DnsFlagsZ'
            type: 'string'
          }
          {
            name: 'DnsResponseCode'
            type: 'string'
          }
          {
            name: 'TransactionIdHex'
            type: 'string'
          }
          {
            name: 'SrcUserScopeId'
            type: 'string'
          }
          {
            name: 'SrcUserScope'
            type: 'string'
          }
          {
            name: 'SrcOriginalRiskLevel'
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
            name: 'SrcDescription'
            type: 'string'
          }
          {
            name: 'DnsSessionId'
            type: 'string'
          }
          {
            name: 'DnsFlagsRecursionDesired'
            type: 'string'
          }
          {
            name: 'DnsFlagsAuthoritative'
            type: 'string'
          }
          {
            name: 'DnsFlagsAuthenticated'
            type: 'string'
          }
          {
            name: 'DnsNetworkDuration'
            type: 'string'
          }
          {
            name: 'DnsQueryClassName'
            type: 'string'
          }
          {
            name: 'DnsQueryClass'
            type: 'string'
          }
          {
            name: 'NetworkProtocol'
            type: 'string'
          }
          {
            name: 'DnsResponseName'
            type: 'string'
          }
          {
            name: 'DnsResponseIpLongitude'
            type: 'string'
          }
          {
            name: 'DnsResponseIpCountry'
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
            name: 'NetworkProtocolVersion'
            type: 'string'
          }
          {
            name: 'EventOriginalSeverity'
            type: 'string'
          }
          {
            name: 'DvcScopeId'
            type: 'string'
          }
          {
            name: 'DvcScope'
            type: 'string'
          }
          {
            name: 'DvcOriginalAction'
            type: 'string'
          }
          {
            name: 'DvcInterface'
            type: 'string'
          }
          {
            name: 'DvcDescription'
            type: 'string'
          }
          {
            name: 'DstRiskLevel'
            type: 'string'
          }
          {
            name: 'DstOriginalRiskLevel'
            type: 'string'
          }
          {
            name: 'DstDvcScope'
            type: 'string'
          }
          {
            name: 'DstDescription'
            type: 'string'
          }
          {
            name: 'DnsResponseIpLatitude'
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
          name: 'Sentinel-ASimDnsActivityLogs'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-ASimDnsActivityLogs']
        destinations: ['Sentinel-ASimDnsActivityLogs']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), EventProductVersion = tostring(EventProductVersion), EventOwner = tostring(EventOwner), DnsResponseIpRegion = tostring(DnsResponseIpRegion), DnsResponseIpCity = tostring(DnsResponseIpCity), DvcZone = tostring(DvcZone), DvcMacAddr = tostring(DvcMacAddr), DvcIdType = tostring(DvcIdType), DvcId = tostring(DvcId), DvcFQDN = tostring(DvcFQDN), Dvc = tostring(Dvc), EventSchemaVersion = tostring(EventSchemaVersion), EventReportUrl = tostring(EventReportUrl), EventOriginalUid = tostring(EventOriginalUid), EventMessage = tostring(EventMessage), EventEndTime = todatetime(EventEndTime), EventStartTime = todatetime(EventStartTime), ThreatLastReportedTime_d = todatetime(ThreatLastReportedTime_d), ThreatLastReportedTime = tostring(ThreatLastReportedTime), ThreatFirstReportedTime_d = todatetime(ThreatFirstReportedTime_d), ThreatFirstReportedTime = tostring(ThreatFirstReportedTime), ThreatIsActive = tobool(ThreatIsActive), ThreatOriginalRiskLevel = toint(ThreatOriginalRiskLevel), ThreatOriginalRiskLevel_s = tostring(ThreatOriginalRiskLevel_s), ThreatRiskLevel = toint(ThreatRiskLevel), ThreatOriginalConfidence = tostring(ThreatOriginalConfidence), ThreatConfidence = toint(ThreatConfidence), ThreatName = tostring(ThreatName), ThreatCategory = tostring(ThreatCategory), UrlCategory = tostring(UrlCategory), EventSeverity = tostring(EventSeverity), Src = tostring(Src), SrcHostname = tostring(SrcHostname), SrcDomain = tostring(SrcDomain), DnsFlagsTruncated = tobool(DnsFlagsTruncated), DnsFlagsRecursionAvailable = tobool(DnsFlagsRecursionAvailable), DnsFlagsCheckingDisabled = tobool(DnsFlagsCheckingDisabled), DnsFlags = tostring(DnsFlags), DvcAction = tostring(DvcAction), DstDeviceType = tostring(DstDeviceType), DstDvcIdType = tostring(DstDvcIdType), DstDvcScopeId = tostring(DstDvcScopeId), DstDvcId = tostring(DstDvcId), DstFQDN = tostring(DstFQDN), DstDomainType = tostring(DstDomainType), DstDomain = tostring(DstDomain), DstHostname = tostring(DstHostname), DstPortNumber = toint(DstPortNumber), ThreatField = tostring(ThreatField), Dst = tostring(Dst), SrcProcessId = tostring(SrcProcessId), SrcProcessName = tostring(SrcProcessName), SrcOriginalUserType = tostring(SrcOriginalUserType), SrcUserType = tostring(SrcUserType), SrcUsernameType = tostring(SrcUsernameType), SrcUsername = tostring(SrcUsername), SrcUserIdType = tostring(SrcUserIdType), SrcUserId = tostring(SrcUserId), SrcRiskLevel = toint(SrcRiskLevel), SrcDeviceType = tostring(SrcDeviceType), SrcDvcIdType = tostring(SrcDvcIdType), SrcDvcId = tostring(SrcDvcId), SrcFQDN = tostring(SrcFQDN), SrcDomainType = tostring(SrcDomainType), SrcProcessGuid = tostring(SrcProcessGuid), ThreatIpAddr = tostring(ThreatIpAddr), ThreatId = tostring(ThreatId), SrcUserSessionId = tostring(SrcUserSessionId), DnsQueryType = toint(DnsQueryType), DnsQuery = tostring(DnsQuery), DstGeoLongitude = toreal(DstGeoLongitude), DstGeoLatitude = toreal(DstGeoLatitude), DstGeoCity = tostring(DstGeoCity), DstGeoRegion = tostring(DstGeoRegion), DstGeoCountry = tostring(DstGeoCountry), DstIpAddr = tostring(DstIpAddr), SrcGeoLongitude = toreal(SrcGeoLongitude), SrcGeoLatitude = toreal(SrcGeoLatitude), SrcGeoCity = tostring(SrcGeoCity), SrcGeoRegion = tostring(SrcGeoRegion), SrcGeoCountry = tostring(SrcGeoCountry), SrcPortNumber = toint(SrcPortNumber), DnsQueryTypeName = tostring(DnsQueryTypeName), SrcIpAddr = tostring(SrcIpAddr), DvcOsVersion = tostring(DvcOsVersion), DvcOs = tostring(DvcOs), DvcDomainType = tostring(DvcDomainType), DvcDomain = tostring(DvcDomain), DvcHostname = tostring(DvcHostname), DvcIpAddr = tostring(DvcIpAddr), EventVendor = tostring(EventVendor), EventProduct = tostring(EventProduct), EventOriginalType = tostring(EventOriginalType), EventResultDetails = tostring(EventResultDetails), EventResult = tostring(EventResult), EventSubType = tostring(EventSubType), EventType = tostring(EventType), EventCount = toint(EventCount), AdditionalFields = todynamic(AdditionalFields), DnsFlagsZ = tobool(DnsFlagsZ), DnsResponseCode = toint(DnsResponseCode), TransactionIdHex = tostring(TransactionIdHex), SrcUserScopeId = tostring(SrcUserScopeId), SrcUserScope = tostring(SrcUserScope), SrcOriginalRiskLevel = tostring(SrcOriginalRiskLevel), SrcDvcScopeId = tostring(SrcDvcScopeId), SrcDvcScope = tostring(SrcDvcScope), SrcDescription = tostring(SrcDescription), DnsSessionId = tostring(DnsSessionId), DnsFlagsRecursionDesired = tobool(DnsFlagsRecursionDesired), DnsFlagsAuthoritative = tobool(DnsFlagsAuthoritative), DnsFlagsAuthenticated = tobool(DnsFlagsAuthenticated), DnsNetworkDuration = toint(DnsNetworkDuration), DnsQueryClassName = tostring(DnsQueryClassName), DnsQueryClass = toint(DnsQueryClass), NetworkProtocol = tostring(NetworkProtocol), DnsResponseName = tostring(DnsResponseName), DnsResponseIpLongitude = toreal(DnsResponseIpLongitude), DnsResponseIpCountry = tostring(DnsResponseIpCountry), RuleNumber = toint(RuleNumber), RuleName = tostring(RuleName), NetworkProtocolVersion = tostring(NetworkProtocolVersion), EventOriginalSeverity = tostring(EventOriginalSeverity), DvcScopeId = tostring(DvcScopeId), DvcScope = tostring(DvcScope), DvcOriginalAction = tostring(DvcOriginalAction), DvcInterface = tostring(DvcInterface), DvcDescription = tostring(DvcDescription), DstRiskLevel = toint(DstRiskLevel), DstOriginalRiskLevel = tostring(DstOriginalRiskLevel), DstDvcScope = tostring(DstDvcScope), DstDescription = tostring(DstDescription), DnsResponseIpLatitude = toreal(DnsResponseIpLatitude), SourceSystem = tostring(SourceSystem)'
        outputStream: 'Microsoft-ASimDnsActivityLogs'
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
