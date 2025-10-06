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
// Data Collection Rule for ASimNetworkSessionLogs
// ============================================================================
// Generated: 2025-09-18 07:50:04
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 143, DCR columns: 141 (Type column always filtered)
// Input stream: Custom-ASimNetworkSessionLogs (always Custom- for JSON ingestion)
// Output stream: Microsoft-ASimNetworkSessionLogs (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-ASimNetworkSessionLogs'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-ASimNetworkSessionLogs': {
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
            name: 'EventReportUrl'
            type: 'string'
          }
          {
            name: 'EventOriginalUid'
            type: 'string'
          }
          {
            name: 'NetworkProtocol'
            type: 'string'
          }
          {
            name: 'DstIpAddr'
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
            name: 'AdditionalFields'
            type: 'dynamic'
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
            name: 'ThreatId'
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
            name: 'ThreatRiskLevel'
            type: 'string'
          }
          {
            name: 'ThreatOriginalRiskLevel'
            type: 'string'
          }
          {
            name: 'EventType'
            type: 'string'
          }
          {
            name: 'SrcFQDN'
            type: 'string'
          }
          {
            name: 'EventSubType'
            type: 'string'
          }
          {
            name: 'EventResultDetails'
            type: 'string'
          }
          {
            name: 'EventOriginalType'
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
            name: 'DvcIpAddr'
            type: 'string'
          }
          {
            name: 'DvcHostname'
            type: 'string'
          }
          {
            name: 'EventResult'
            type: 'string'
          }
          {
            name: 'NetworkRuleNumber'
            type: 'string'
          }
          {
            name: 'SrcDvcId'
            type: 'string'
          }
          {
            name: 'ThreatIpAddr'
            type: 'string'
          }
          {
            name: 'DstDescription'
            type: 'string'
          }
          {
            name: 'ThreatOriginalConfidence'
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
            name: 'EventOriginalResultDetails'
            type: 'string'
          }
          {
            name: 'DvcDescription'
            type: 'string'
          }
          {
            name: 'NetworkDuration'
            type: 'string'
          }
          {
            name: 'ThreatConfidence'
            type: 'string'
          }
          {
            name: 'ThreatIsActive'
            type: 'string'
          }
          {
            name: 'ThreatField'
            type: 'string'
          }
          {
            name: 'TcpFlagsSyn'
            type: 'string'
          }
          {
            name: 'TcpFlagsUrg'
            type: 'string'
          }
          {
            name: 'TcpFlagsRst'
            type: 'string'
          }
          {
            name: 'TcpFlagsPsh'
            type: 'string'
          }
          {
            name: 'TcpFlagsFin'
            type: 'string'
          }
          {
            name: 'TcpFlagsAck'
            type: 'string'
          }
          {
            name: 'DstDeviceType'
            type: 'string'
          }
          {
            name: 'SrcDeviceType'
            type: 'string'
          }
          {
            name: 'SrcUserId'
            type: 'string'
          }
          {
            name: 'SrcUserIdType'
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
            name: 'SrcDvcIdType'
            type: 'string'
          }
          {
            name: 'SrcOriginalUserType'
            type: 'string'
          }
          {
            name: 'DstHostname'
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
            name: 'DstPortNumber'
            type: 'string'
          }
          {
            name: 'NetworkRuleName'
            type: 'string'
          }
          {
            name: 'DvcOutboundInterface'
            type: 'string'
          }
          {
            name: 'DvcInboundInterface'
            type: 'string'
          }
          {
            name: 'DstInterfaceName'
            type: 'string'
          }
          {
            name: 'DstZone'
            type: 'string'
          }
          {
            name: 'NetworkSessionId'
            type: 'string'
          }
          {
            name: 'NetworkPackets'
            type: 'string'
          }
          {
            name: 'SrcPackets'
            type: 'string'
          }
          {
            name: 'DstPackets'
            type: 'string'
          }
          {
            name: 'NetworkBytes'
            type: 'string'
          }
          {
            name: 'SrcBytes'
            type: 'string'
          }
          {
            name: 'DstBytes'
            type: 'string'
          }
          {
            name: 'NetworkConnectionHistory'
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
            name: 'NetworkDirection'
            type: 'string'
          }
          {
            name: 'NetworkProtocolVersion'
            type: 'string'
          }
          {
            name: 'NetworkApplicationProtocol'
            type: 'string'
          }
          {
            name: 'EventOriginalSubType'
            type: 'string'
          }
          {
            name: 'EventOriginalSeverity'
            type: 'string'
          }
          {
            name: 'EventCount'
            type: 'string'
          }
          {
            name: 'EventSchemaVersion'
            type: 'string'
          }
          {
            name: 'DvcAction'
            type: 'string'
          }
          {
            name: 'EventMessage'
            type: 'string'
          }
          {
            name: 'EventSeverity'
            type: 'string'
          }
          {
            name: 'EventStartTime'
            type: 'string'
          }
          {
            name: 'DstInterfaceGuid'
            type: 'string'
          }
          {
            name: 'EventEndTime'
            type: 'string'
          }
          {
            name: 'Dvc'
            type: 'string'
          }
          {
            name: 'DvcZone'
            type: 'string'
          }
          {
            name: 'EventProductVersion'
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
            name: 'DvcSubscriptionId'
            type: 'string'
          }
          {
            name: 'DvcMacAddr'
            type: 'string'
          }
          {
            name: 'DstMacAddr'
            type: 'string'
          }
          {
            name: 'DstVlanId'
            type: 'string'
          }
          {
            name: 'DstSubscriptionId'
            type: 'string'
          }
          {
            name: 'SrcVlanId'
            type: 'string'
          }
          {
            name: 'SrcSubscriptionId'
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
            name: 'SrcMacAddr'
            type: 'string'
          }
          {
            name: 'SrcGeoLongitude'
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
            name: 'SrcNatPortNumber'
            type: 'string'
          }
          {
            name: 'SrcAppName'
            type: 'string'
          }
          {
            name: 'SrcDescription'
            type: 'string'
          }
          {
            name: 'SrcInterfaceGuid'
            type: 'string'
          }
          {
            name: 'SrcZone'
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
            name: 'SrcInterfaceName'
            type: 'string'
          }
          {
            name: 'DstUserIdType'
            type: 'string'
          }
          {
            name: 'DstUsernameType'
            type: 'string'
          }
          {
            name: 'DstUserType'
            type: 'string'
          }
          {
            name: 'DstOriginalUserType'
            type: 'string'
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
            name: 'DstAppType'
            type: 'string'
          }
          {
            name: 'DstUsername'
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
          name: 'Sentinel-ASimNetworkSessionLogs'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-ASimNetworkSessionLogs']
        destinations: ['Sentinel-ASimNetworkSessionLogs']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), SrcDomainType = tostring(SrcDomainType), SrcDomain = tostring(SrcDomain), SrcHostname = tostring(SrcHostname), DvcIdType = tostring(DvcIdType), DvcId = tostring(DvcId), DvcFQDN = tostring(DvcFQDN), EventReportUrl = tostring(EventReportUrl), EventOriginalUid = tostring(EventOriginalUid), NetworkProtocol = tostring(NetworkProtocol), DstIpAddr = tostring(DstIpAddr), SrcPortNumber = toint(SrcPortNumber), SrcIpAddr = tostring(SrcIpAddr), AdditionalFields = todynamic(AdditionalFields), DvcOsVersion = tostring(DvcOsVersion), DvcOs = tostring(DvcOs), DvcDomainType = tostring(DvcDomainType), DvcDomain = tostring(DvcDomain), ThreatId = tostring(ThreatId), ThreatName = tostring(ThreatName), ThreatCategory = tostring(ThreatCategory), ThreatRiskLevel = toint(ThreatRiskLevel), ThreatOriginalRiskLevel = tostring(ThreatOriginalRiskLevel), EventType = tostring(EventType), SrcFQDN = tostring(SrcFQDN), EventSubType = tostring(EventSubType), EventResultDetails = tostring(EventResultDetails), EventOriginalType = tostring(EventOriginalType), EventProduct = tostring(EventProduct), EventVendor = tostring(EventVendor), DvcIpAddr = tostring(DvcIpAddr), DvcHostname = tostring(DvcHostname), EventResult = tostring(EventResult), NetworkRuleNumber = toint(NetworkRuleNumber), SrcDvcId = tostring(SrcDvcId), ThreatIpAddr = tostring(ThreatIpAddr), DstDescription = tostring(DstDescription), ThreatOriginalConfidence = tostring(ThreatOriginalConfidence), ThreatLastReportedTime = todatetime(ThreatLastReportedTime), ThreatFirstReportedTime = todatetime(ThreatFirstReportedTime), EventOriginalResultDetails = tostring(EventOriginalResultDetails), DvcDescription = tostring(DvcDescription), NetworkDuration = toint(NetworkDuration), ThreatConfidence = toint(ThreatConfidence), ThreatIsActive = tobool(ThreatIsActive), ThreatField = tostring(ThreatField), TcpFlagsSyn = tobool(TcpFlagsSyn), TcpFlagsUrg = tobool(TcpFlagsUrg), TcpFlagsRst = tobool(TcpFlagsRst), TcpFlagsPsh = tobool(TcpFlagsPsh), TcpFlagsFin = tobool(TcpFlagsFin), TcpFlagsAck = tobool(TcpFlagsAck), DstDeviceType = tostring(DstDeviceType), SrcDeviceType = tostring(SrcDeviceType), SrcUserId = tostring(SrcUserId), SrcUserIdType = tostring(SrcUserIdType), SrcUsername = tostring(SrcUsername), SrcUsernameType = tostring(SrcUsernameType), SrcUserType = tostring(SrcUserType), SrcDvcIdType = tostring(SrcDvcIdType), SrcOriginalUserType = tostring(SrcOriginalUserType), DstHostname = tostring(DstHostname), DstDomain = tostring(DstDomain), DstDomainType = tostring(DstDomainType), DstFQDN = tostring(DstFQDN), DstDvcId = tostring(DstDvcId), DstDvcIdType = tostring(DstDvcIdType), DstPortNumber = toint(DstPortNumber), NetworkRuleName = tostring(NetworkRuleName), DvcOutboundInterface = tostring(DvcOutboundInterface), DvcInboundInterface = tostring(DvcInboundInterface), DstInterfaceName = tostring(DstInterfaceName), DstZone = tostring(DstZone), NetworkSessionId = tostring(NetworkSessionId), NetworkPackets = tolong(NetworkPackets), SrcPackets = tolong(SrcPackets), DstPackets = tolong(DstPackets), NetworkBytes = tolong(NetworkBytes), SrcBytes = tolong(SrcBytes), DstBytes = tolong(DstBytes), NetworkConnectionHistory = tostring(NetworkConnectionHistory), NetworkIcmpType = tostring(NetworkIcmpType), NetworkIcmpCode = toint(NetworkIcmpCode), NetworkDirection = tostring(NetworkDirection), NetworkProtocolVersion = tostring(NetworkProtocolVersion), NetworkApplicationProtocol = tostring(NetworkApplicationProtocol), EventOriginalSubType = tostring(EventOriginalSubType), EventOriginalSeverity = tostring(EventOriginalSeverity), EventCount = toint(EventCount), EventSchemaVersion = tostring(EventSchemaVersion), DvcAction = tostring(DvcAction), EventMessage = tostring(EventMessage), EventSeverity = tostring(EventSeverity), EventStartTime = todatetime(EventStartTime), DstInterfaceGuid = tostring(DstInterfaceGuid), EventEndTime = todatetime(EventEndTime), Dvc = tostring(Dvc), DvcZone = tostring(DvcZone), EventProductVersion = tostring(EventProductVersion), DvcOriginalAction = tostring(DvcOriginalAction), DvcInterface = tostring(DvcInterface), DvcSubscriptionId = tostring(DvcSubscriptionId), DvcMacAddr = tostring(DvcMacAddr), DstMacAddr = tostring(DstMacAddr), DstVlanId = tostring(DstVlanId), DstSubscriptionId = tostring(DstSubscriptionId), SrcVlanId = tostring(SrcVlanId), SrcSubscriptionId = tostring(SrcSubscriptionId), SrcGeoCountry = tostring(SrcGeoCountry), SrcGeoRegion = tostring(SrcGeoRegion), SrcGeoCity = tostring(SrcGeoCity), SrcGeoLatitude = toreal(SrcGeoLatitude), SrcMacAddr = tostring(SrcMacAddr), SrcGeoLongitude = toreal(SrcGeoLongitude), SrcAppId = tostring(SrcAppId), SrcAppType = tostring(SrcAppType), DstNatIpAddr = tostring(DstNatIpAddr), DstNatPortNumber = toint(DstNatPortNumber), SrcNatIpAddr = tostring(SrcNatIpAddr), SrcNatPortNumber = toint(SrcNatPortNumber), SrcAppName = tostring(SrcAppName), SrcDescription = tostring(SrcDescription), SrcInterfaceGuid = tostring(SrcInterfaceGuid), SrcZone = tostring(SrcZone), DstGeoCountry = tostring(DstGeoCountry), DstGeoRegion = tostring(DstGeoRegion), DstGeoCity = tostring(DstGeoCity), DstGeoLatitude = toreal(DstGeoLatitude), DstGeoLongitude = toreal(DstGeoLongitude), DstUserId = tostring(DstUserId), SrcInterfaceName = tostring(SrcInterfaceName), DstUserIdType = tostring(DstUserIdType), DstUsernameType = tostring(DstUsernameType), DstUserType = tostring(DstUserType), DstOriginalUserType = tostring(DstOriginalUserType), DstAppName = tostring(DstAppName), DstAppId = tostring(DstAppId), DstAppType = tostring(DstAppType), DstUsername = tostring(DstUsername), SourceSystem = tostring(SourceSystem)'
        outputStream: 'Microsoft-ASimNetworkSessionLogs'
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
