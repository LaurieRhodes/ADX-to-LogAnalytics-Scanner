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
// Data Collection Rule for ASimFileEventLogs
// ============================================================================
// Generated: 2025-09-18 07:50:02
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 125, DCR columns: 123 (Type column always filtered)
// Input stream: Custom-ASimFileEventLogs (always Custom- for JSON ingestion)
// Output stream: Microsoft-ASimFileEventLogs (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-ASimFileEventLogs'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-ASimFileEventLogs': {
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
            name: 'SrcRiskLevel'
            type: 'string'
          }
          {
            name: 'SrcPortNumber'
            type: 'string'
          }
          {
            name: 'SrcOriginalRiskLevel'
            type: 'string'
          }
          {
            name: 'NetworkApplicationProtocol'
            type: 'string'
          }
          {
            name: 'HttpUserAgent'
            type: 'string'
          }
          {
            name: 'ActingProcessGuid'
            type: 'string'
          }
          {
            name: 'ActingProcessId'
            type: 'string'
          }
          {
            name: 'SrcDvcScope'
            type: 'string'
          }
          {
            name: 'ActingProcessName'
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
            name: 'ActorSessionId'
            type: 'string'
          }
          {
            name: 'ActorUsernameType'
            type: 'string'
          }
          {
            name: 'ActorUserIdType'
            type: 'string'
          }
          {
            name: 'ActorScopeId'
            type: 'string'
          }
          {
            name: 'ActorScope'
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
            name: 'SrcFileSize'
            type: 'string'
          }
          {
            name: 'SrcFileSHA512'
            type: 'string'
          }
          {
            name: 'SrcFileSHA256'
            type: 'string'
          }
          {
            name: 'ActingProcessCommandLine'
            type: 'string'
          }
          {
            name: 'SrcDvcIdType'
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
            name: 'ThreatFilePath'
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
            name: 'TargetAppId'
            type: 'string'
          }
          {
            name: 'TargetAppName'
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
            name: 'SrcFileSHA1'
            type: 'string'
          }
          {
            name: 'SrcFileMD5'
            type: 'string'
          }
          {
            name: 'SrcFileMimeType'
            type: 'string'
          }
          {
            name: 'SrcFileExtension'
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
            name: 'SrcIpAddr'
            type: 'string'
          }
          {
            name: 'ActorUserId'
            type: 'string'
          }
          {
            name: 'SrcFilePathType'
            type: 'string'
          }
          {
            name: 'SrcFilePath'
            type: 'string'
          }
          {
            name: 'SrcFileName'
            type: 'string'
          }
          {
            name: 'HashType'
            type: 'string'
          }
          {
            name: 'TargetFileName'
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
            name: 'ActorUsername'
            type: 'string'
          }
          {
            name: 'TargetFilePathType'
            type: 'string'
          }
          {
            name: 'TargetFilePath'
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
            name: 'EventMessage'
            type: 'string'
          }
          {
            name: 'AdditionalFields'
            type: 'dynamic'
          }
          {
            name: 'EventCount'
            type: 'string'
          }
          {
            name: 'EventOriginalUid'
            type: 'string'
          }
          {
            name: 'SrcFileDirectory'
            type: 'string'
          }
          {
            name: 'SrcFileCreationTime'
            type: 'string'
          }
          {
            name: 'TargetFileSize'
            type: 'string'
          }
          {
            name: 'TargetFileSHA512'
            type: 'string'
          }
          {
            name: 'TargetFileSHA256'
            type: 'string'
          }
          {
            name: 'TargetFileSHA1'
            type: 'string'
          }
          {
            name: 'TargetFileMD5'
            type: 'string'
          }
          {
            name: 'TargetFileMimeType'
            type: 'string'
          }
          {
            name: 'TargetFileExtension'
            type: 'string'
          }
          {
            name: 'TargetFileDirectory'
            type: 'string'
          }
          {
            name: 'TargetFileCreationTime'
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
            name: 'EventOwner'
            type: 'string'
          }
          {
            name: 'EventReportUrl'
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
            name: 'EventSubType'
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
          name: 'Sentinel-ASimFileEventLogs'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-ASimFileEventLogs']
        destinations: ['Sentinel-ASimFileEventLogs']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), SrcDvcScopeId = tostring(SrcDvcScopeId), SrcDvcId = tostring(SrcDvcId), SrcDescription = tostring(SrcDescription), SrcFQDN = tostring(SrcFQDN), SrcDomainType = tostring(SrcDomainType), SrcRiskLevel = toint(SrcRiskLevel), SrcPortNumber = toint(SrcPortNumber), SrcOriginalRiskLevel = tostring(SrcOriginalRiskLevel), NetworkApplicationProtocol = tostring(NetworkApplicationProtocol), HttpUserAgent = tostring(HttpUserAgent), ActingProcessGuid = tostring(ActingProcessGuid), ActingProcessId = tostring(ActingProcessId), SrcDvcScope = tostring(SrcDvcScope), ActingProcessName = tostring(ActingProcessName), ActorOriginalUserType = tostring(ActorOriginalUserType), ActorUserType = tostring(ActorUserType), ActorSessionId = tostring(ActorSessionId), ActorUsernameType = tostring(ActorUsernameType), ActorUserIdType = tostring(ActorUserIdType), ActorScopeId = tostring(ActorScopeId), ActorScope = tostring(ActorScope), ActorUserSid = tostring(ActorUserSid), ActorUserAadId = tostring(ActorUserAadId), SrcFileSize = tolong(SrcFileSize), SrcFileSHA512 = tostring(SrcFileSHA512), SrcFileSHA256 = tostring(SrcFileSHA256), ActingProcessCommandLine = tostring(ActingProcessCommandLine), SrcDvcIdType = tostring(SrcDvcIdType), SrcDeviceType = tostring(SrcDeviceType), SrcGeoCountry = tostring(SrcGeoCountry), EventEndTime = todatetime(EventEndTime), EventStartTime = todatetime(EventStartTime), EventSchemaVersion = tostring(EventSchemaVersion), EventSchema = tostring(EventSchema), ThreatLastReportedTime = todatetime(ThreatLastReportedTime), ThreatFirstReportedTime = todatetime(ThreatFirstReportedTime), ThreatIsActive = tobool(ThreatIsActive), ThreatOriginalConfidence = tostring(ThreatOriginalConfidence), ThreatConfidence = toint(ThreatConfidence), ThreatField = tostring(ThreatField), ThreatFilePath = tostring(ThreatFilePath), ThreatOriginalRiskLevel = tostring(ThreatOriginalRiskLevel), ThreatRiskLevel = toint(ThreatRiskLevel), ThreatCategory = tostring(ThreatCategory), ThreatName = tostring(ThreatName), ThreatId = tostring(ThreatId), RuleNumber = toint(RuleNumber), RuleName = tostring(RuleName), TargetUrl = tostring(TargetUrl), TargetOriginalAppType = tostring(TargetOriginalAppType), TargetAppType = tostring(TargetAppType), TargetAppId = tostring(TargetAppId), TargetAppName = tostring(TargetAppName), SrcGeoLongitude = toreal(SrcGeoLongitude), SrcGeoLatitude = toreal(SrcGeoLatitude), SrcGeoCity = tostring(SrcGeoCity), SrcGeoRegion = tostring(SrcGeoRegion), SrcFileSHA1 = tostring(SrcFileSHA1), SrcFileMD5 = tostring(SrcFileMD5), SrcFileMimeType = tostring(SrcFileMimeType), SrcFileExtension = tostring(SrcFileExtension), SrcDomain = tostring(SrcDomain), SrcMacAddr = tostring(SrcMacAddr), SrcHostname = tostring(SrcHostname), SrcIpAddr = tostring(SrcIpAddr), ActorUserId = tostring(ActorUserId), SrcFilePathType = tostring(SrcFilePathType), SrcFilePath = tostring(SrcFilePath), SrcFileName = tostring(SrcFileName), HashType = tostring(HashType), TargetFileName = tostring(TargetFileName), DvcAction = tostring(DvcAction), DvcIdType = tostring(DvcIdType), DvcId = tostring(DvcId), DvcFQDN = tostring(DvcFQDN), DvcDomainType = tostring(DvcDomainType), DvcDomain = tostring(DvcDomain), DvcHostname = tostring(DvcHostname), DvcIpAddr = tostring(DvcIpAddr), EventResultDetails = tostring(EventResultDetails), ActorUsername = tostring(ActorUsername), TargetFilePathType = tostring(TargetFilePathType), TargetFilePath = tostring(TargetFilePath), EventType = tostring(EventType), EventSeverity = tostring(EventSeverity), EventResult = tostring(EventResult), EventVendor = tostring(EventVendor), EventProduct = tostring(EventProduct), EventMessage = tostring(EventMessage), AdditionalFields = todynamic(AdditionalFields), EventCount = toint(EventCount), EventOriginalUid = tostring(EventOriginalUid), SrcFileDirectory = tostring(SrcFileDirectory), SrcFileCreationTime = todatetime(SrcFileCreationTime), TargetFileSize = tolong(TargetFileSize), TargetFileSHA512 = tostring(TargetFileSHA512), TargetFileSHA256 = tostring(TargetFileSHA256), TargetFileSHA1 = tostring(TargetFileSHA1), TargetFileMD5 = tostring(TargetFileMD5), TargetFileMimeType = tostring(TargetFileMimeType), TargetFileExtension = tostring(TargetFileExtension), TargetFileDirectory = tostring(TargetFileDirectory), TargetFileCreationTime = todatetime(TargetFileCreationTime), DvcScope = tostring(DvcScope), DvcScopeId = tostring(DvcScopeId), DvcInterface = tostring(DvcInterface), DvcOriginalAction = tostring(DvcOriginalAction), DvcOsVersion = tostring(DvcOsVersion), DvcOs = tostring(DvcOs), DvcZone = tostring(DvcZone), DvcMacAddr = tostring(DvcMacAddr), DvcDescription = tostring(DvcDescription), EventOwner = tostring(EventOwner), EventReportUrl = tostring(EventReportUrl), EventProductVersion = tostring(EventProductVersion), EventOriginalSeverity = tostring(EventOriginalSeverity), EventOriginalResultDetails = tostring(EventOriginalResultDetails), EventOriginalSubType = tostring(EventOriginalSubType), EventOriginalType = tostring(EventOriginalType), EventSubType = tostring(EventSubType), SourceSystem = tostring(SourceSystem)'
        outputStream: 'Microsoft-ASimFileEventLogs'
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
