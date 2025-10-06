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
// Data Collection Rule for CommonSecurityLog
// ============================================================================
// Generated: 2025-09-18 07:50:23
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 160, DCR columns: 158 (Type column always filtered)
// Input stream: Custom-CommonSecurityLog (always Custom- for JSON ingestion)
// Output stream: Microsoft-CommonSecurityLog (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-CommonSecurityLog'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-CommonSecurityLog': {
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
            name: 'DeviceCustomFloatingPoint1Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomFloatingPoint2'
            type: 'string'
          }
          {
            name: 'DeviceCustomFloatingPoint2Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomFloatingPoint3'
            type: 'string'
          }
          {
            name: 'DeviceCustomFloatingPoint3Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomFloatingPoint4'
            type: 'string'
          }
          {
            name: 'DeviceCustomFloatingPoint4Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomNumber1'
            type: 'string'
          }
          {
            name: 'FieldDeviceCustomNumber1'
            type: 'string'
          }
          {
            name: 'DeviceCustomNumber1Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomNumber2'
            type: 'string'
          }
          {
            name: 'FieldDeviceCustomNumber2'
            type: 'string'
          }
          {
            name: 'DeviceCustomNumber2Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomNumber3'
            type: 'string'
          }
          {
            name: 'FieldDeviceCustomNumber3'
            type: 'string'
          }
          {
            name: 'DeviceCustomFloatingPoint1'
            type: 'string'
          }
          {
            name: 'DeviceCustomIPv6Address4Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomIPv6Address4'
            type: 'string'
          }
          {
            name: 'DeviceCustomIPv6Address3Label'
            type: 'string'
          }
          {
            name: 'SourceTranslatedPort'
            type: 'string'
          }
          {
            name: 'SourceProcessId'
            type: 'string'
          }
          {
            name: 'SourceUserPrivileges'
            type: 'string'
          }
          {
            name: 'SourceProcessName'
            type: 'string'
          }
          {
            name: 'SourcePort'
            type: 'string'
          }
          {
            name: 'SourceIP'
            type: 'string'
          }
          {
            name: 'StartTime'
            type: 'string'
          }
          {
            name: 'DeviceCustomNumber3Label'
            type: 'string'
          }
          {
            name: 'SourceUserID'
            type: 'string'
          }
          {
            name: 'EventType'
            type: 'string'
          }
          {
            name: 'DeviceEventCategory'
            type: 'string'
          }
          {
            name: 'DeviceCustomIPv6Address1'
            type: 'string'
          }
          {
            name: 'DeviceCustomIPv6Address1Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomIPv6Address2'
            type: 'string'
          }
          {
            name: 'DeviceCustomIPv6Address2Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomIPv6Address3'
            type: 'string'
          }
          {
            name: 'SourceUserName'
            type: 'string'
          }
          {
            name: 'DeviceCustomString1'
            type: 'string'
          }
          {
            name: 'DeviceCustomString1Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomString2'
            type: 'string'
          }
          {
            name: 'FlexString1Label'
            type: 'string'
          }
          {
            name: 'FlexString2'
            type: 'string'
          }
          {
            name: 'FlexString2Label'
            type: 'string'
          }
          {
            name: 'RemoteIP'
            type: 'string'
          }
          {
            name: 'RemotePort'
            type: 'string'
          }
          {
            name: 'MaliciousIP'
            type: 'string'
          }
          {
            name: 'ThreatSeverity'
            type: 'string'
          }
          {
            name: 'FlexString1'
            type: 'string'
          }
          {
            name: 'IndicatorThreatType'
            type: 'string'
          }
          {
            name: 'ThreatConfidence'
            type: 'string'
          }
          {
            name: 'ReportReferenceLink'
            type: 'string'
          }
          {
            name: 'MaliciousIPLongitude'
            type: 'string'
          }
          {
            name: 'MaliciousIPLatitude'
            type: 'string'
          }
          {
            name: 'MaliciousIPCountry'
            type: 'string'
          }
          {
            name: 'Computer'
            type: 'string'
          }
          {
            name: 'SourceSystem'
            type: 'string'
          }
          {
            name: 'ThreatDescription'
            type: 'string'
          }
          {
            name: 'SourceTranslatedAddress'
            type: 'string'
          }
          {
            name: 'FlexNumber2Label'
            type: 'string'
          }
          {
            name: 'FlexNumber1Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomString2Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomString3'
            type: 'string'
          }
          {
            name: 'DeviceCustomString3Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomString4'
            type: 'string'
          }
          {
            name: 'DeviceCustomString4Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomString5'
            type: 'string'
          }
          {
            name: 'DeviceCustomString5Label'
            type: 'string'
          }
          {
            name: 'FlexNumber2'
            type: 'string'
          }
          {
            name: 'DeviceCustomString6'
            type: 'string'
          }
          {
            name: 'DeviceCustomDate1'
            type: 'string'
          }
          {
            name: 'DeviceCustomDate1Label'
            type: 'string'
          }
          {
            name: 'DeviceCustomDate2'
            type: 'string'
          }
          {
            name: 'DeviceCustomDate2Label'
            type: 'string'
          }
          {
            name: 'FlexDate1'
            type: 'string'
          }
          {
            name: 'FlexDate1Label'
            type: 'string'
          }
          {
            name: 'FlexNumber1'
            type: 'string'
          }
          {
            name: 'DeviceCustomString6Label'
            type: 'string'
          }
          {
            name: 'SimplifiedDeviceAction'
            type: 'string'
          }
          {
            name: 'SourceServiceName'
            type: 'string'
          }
          {
            name: 'SourceNTDomain'
            type: 'string'
          }
          {
            name: 'DeviceNtDomain'
            type: 'string'
          }
          {
            name: 'DeviceOutboundInterface'
            type: 'string'
          }
          {
            name: 'DevicePayloadId'
            type: 'string'
          }
          {
            name: 'ProcessName'
            type: 'string'
          }
          {
            name: 'DeviceTranslatedAddress'
            type: 'string'
          }
          {
            name: 'DestinationHostName'
            type: 'string'
          }
          {
            name: 'DestinationMACAddress'
            type: 'string'
          }
          {
            name: 'DestinationNTDomain'
            type: 'string'
          }
          {
            name: 'DestinationProcessId'
            type: 'string'
          }
          {
            name: 'DestinationUserPrivileges'
            type: 'string'
          }
          {
            name: 'DestinationProcessName'
            type: 'string'
          }
          {
            name: 'DestinationPort'
            type: 'string'
          }
          {
            name: 'DestinationIP'
            type: 'string'
          }
          {
            name: 'DeviceTimeZone'
            type: 'string'
          }
          {
            name: 'DestinationUserID'
            type: 'string'
          }
          {
            name: 'DeviceInboundInterface'
            type: 'string'
          }
          {
            name: 'DeviceFacility'
            type: 'string'
          }
          {
            name: 'DeviceExternalID'
            type: 'string'
          }
          {
            name: 'DeviceDnsDomain'
            type: 'string'
          }
          {
            name: 'DeviceVendor'
            type: 'string'
          }
          {
            name: 'DeviceProduct'
            type: 'string'
          }
          {
            name: 'DeviceVersion'
            type: 'string'
          }
          {
            name: 'DeviceEventClassID'
            type: 'string'
          }
          {
            name: 'Activity'
            type: 'string'
          }
          {
            name: 'LogSeverity'
            type: 'string'
          }
          {
            name: 'OriginalLogSeverity'
            type: 'string'
          }
          {
            name: 'DestinationUserName'
            type: 'string'
          }
          {
            name: 'AdditionalExtensions'
            type: 'string'
          }
          {
            name: 'ApplicationProtocol'
            type: 'string'
          }
          {
            name: 'EventCount'
            type: 'string'
          }
          {
            name: 'DestinationDnsDomain'
            type: 'string'
          }
          {
            name: 'DestinationServiceName'
            type: 'string'
          }
          {
            name: 'DestinationTranslatedAddress'
            type: 'string'
          }
          {
            name: 'DestinationTranslatedPort'
            type: 'string'
          }
          {
            name: 'CommunicationDirection'
            type: 'string'
          }
          {
            name: 'DeviceAction'
            type: 'string'
          }
          {
            name: 'DeviceAddress'
            type: 'string'
          }
          {
            name: 'DeviceName'
            type: 'string'
          }
          {
            name: 'DeviceMacAddress'
            type: 'string'
          }
          {
            name: 'OldFilePath'
            type: 'string'
          }
          {
            name: 'OldFilePermission'
            type: 'string'
          }
          {
            name: 'OldFileSize'
            type: 'string'
          }
          {
            name: 'OldFileType'
            type: 'string'
          }
          {
            name: 'SentBytes'
            type: 'string'
          }
          {
            name: 'EventOutcome'
            type: 'string'
          }
          {
            name: 'Protocol'
            type: 'string'
          }
          {
            name: 'OldFileName'
            type: 'string'
          }
          {
            name: 'Reason'
            type: 'string'
          }
          {
            name: 'RequestClientApplication'
            type: 'string'
          }
          {
            name: 'RequestContext'
            type: 'string'
          }
          {
            name: 'RequestCookies'
            type: 'string'
          }
          {
            name: 'RequestMethod'
            type: 'string'
          }
          {
            name: 'ReceiptTime'
            type: 'string'
          }
          {
            name: 'SourceHostName'
            type: 'string'
          }
          {
            name: 'SourceMACAddress'
            type: 'string'
          }
          {
            name: 'RequestURL'
            type: 'string'
          }
          {
            name: 'SourceDnsDomain'
            type: 'string'
          }
          {
            name: 'OldFileModificationTime'
            type: 'string'
          }
          {
            name: 'OldFileHash'
            type: 'string'
          }
          {
            name: 'ProcessID'
            type: 'string'
          }
          {
            name: 'EndTime'
            type: 'string'
          }
          {
            name: 'ExternalID'
            type: 'string'
          }
          {
            name: 'ExtID'
            type: 'string'
          }
          {
            name: 'FileCreateTime'
            type: 'string'
          }
          {
            name: 'FileHash'
            type: 'string'
          }
          {
            name: 'FileID'
            type: 'string'
          }
          {
            name: 'OldFileID'
            type: 'string'
          }
          {
            name: 'FileModificationTime'
            type: 'string'
          }
          {
            name: 'FilePermission'
            type: 'string'
          }
          {
            name: 'FileType'
            type: 'string'
          }
          {
            name: 'FileName'
            type: 'string'
          }
          {
            name: 'FileSize'
            type: 'string'
          }
          {
            name: 'ReceivedBytes'
            type: 'string'
          }
          {
            name: 'Message'
            type: 'string'
          }
          {
            name: 'OldFileCreateTime'
            type: 'string'
          }
          {
            name: 'FilePath'
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
          name: 'Sentinel-CommonSecurityLog'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-CommonSecurityLog']
        destinations: ['Sentinel-CommonSecurityLog']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), DeviceCustomFloatingPoint1Label = tostring(DeviceCustomFloatingPoint1Label), DeviceCustomFloatingPoint2 = toreal(DeviceCustomFloatingPoint2), DeviceCustomFloatingPoint2Label = tostring(DeviceCustomFloatingPoint2Label), DeviceCustomFloatingPoint3 = toreal(DeviceCustomFloatingPoint3), DeviceCustomFloatingPoint3Label = tostring(DeviceCustomFloatingPoint3Label), DeviceCustomFloatingPoint4 = toreal(DeviceCustomFloatingPoint4), DeviceCustomFloatingPoint4Label = tostring(DeviceCustomFloatingPoint4Label), DeviceCustomNumber1 = toint(DeviceCustomNumber1), FieldDeviceCustomNumber1 = tolong(FieldDeviceCustomNumber1), DeviceCustomNumber1Label = tostring(DeviceCustomNumber1Label), DeviceCustomNumber2 = toint(DeviceCustomNumber2), FieldDeviceCustomNumber2 = tolong(FieldDeviceCustomNumber2), DeviceCustomNumber2Label = tostring(DeviceCustomNumber2Label), DeviceCustomNumber3 = toint(DeviceCustomNumber3), FieldDeviceCustomNumber3 = tolong(FieldDeviceCustomNumber3), DeviceCustomFloatingPoint1 = toreal(DeviceCustomFloatingPoint1), DeviceCustomIPv6Address4Label = tostring(DeviceCustomIPv6Address4Label), DeviceCustomIPv6Address4 = tostring(DeviceCustomIPv6Address4), DeviceCustomIPv6Address3Label = tostring(DeviceCustomIPv6Address3Label), SourceTranslatedPort = toint(SourceTranslatedPort), SourceProcessId = toint(SourceProcessId), SourceUserPrivileges = tostring(SourceUserPrivileges), SourceProcessName = tostring(SourceProcessName), SourcePort = toint(SourcePort), SourceIP = tostring(SourceIP), StartTime = todatetime(StartTime), DeviceCustomNumber3Label = tostring(DeviceCustomNumber3Label), SourceUserID = tostring(SourceUserID), EventType = toint(EventType), DeviceEventCategory = tostring(DeviceEventCategory), DeviceCustomIPv6Address1 = tostring(DeviceCustomIPv6Address1), DeviceCustomIPv6Address1Label = tostring(DeviceCustomIPv6Address1Label), DeviceCustomIPv6Address2 = tostring(DeviceCustomIPv6Address2), DeviceCustomIPv6Address2Label = tostring(DeviceCustomIPv6Address2Label), DeviceCustomIPv6Address3 = tostring(DeviceCustomIPv6Address3), SourceUserName = tostring(SourceUserName), DeviceCustomString1 = tostring(DeviceCustomString1), DeviceCustomString1Label = tostring(DeviceCustomString1Label), DeviceCustomString2 = tostring(DeviceCustomString2), FlexString1Label = tostring(FlexString1Label), FlexString2 = tostring(FlexString2), FlexString2Label = tostring(FlexString2Label), RemoteIP = tostring(RemoteIP), RemotePort = tostring(RemotePort), MaliciousIP = tostring(MaliciousIP), ThreatSeverity = toint(ThreatSeverity), FlexString1 = tostring(FlexString1), IndicatorThreatType = tostring(IndicatorThreatType), ThreatConfidence = tostring(ThreatConfidence), ReportReferenceLink = tostring(ReportReferenceLink), MaliciousIPLongitude = toreal(MaliciousIPLongitude), MaliciousIPLatitude = toreal(MaliciousIPLatitude), MaliciousIPCountry = tostring(MaliciousIPCountry), Computer = tostring(Computer), SourceSystem = tostring(SourceSystem), ThreatDescription = tostring(ThreatDescription), SourceTranslatedAddress = tostring(SourceTranslatedAddress), FlexNumber2Label = tostring(FlexNumber2Label), FlexNumber1Label = tostring(FlexNumber1Label), DeviceCustomString2Label = tostring(DeviceCustomString2Label), DeviceCustomString3 = tostring(DeviceCustomString3), DeviceCustomString3Label = tostring(DeviceCustomString3Label), DeviceCustomString4 = tostring(DeviceCustomString4), DeviceCustomString4Label = tostring(DeviceCustomString4Label), DeviceCustomString5 = tostring(DeviceCustomString5), DeviceCustomString5Label = tostring(DeviceCustomString5Label), FlexNumber2 = toint(FlexNumber2), DeviceCustomString6 = tostring(DeviceCustomString6), DeviceCustomDate1 = tostring(DeviceCustomDate1), DeviceCustomDate1Label = tostring(DeviceCustomDate1Label), DeviceCustomDate2 = tostring(DeviceCustomDate2), DeviceCustomDate2Label = tostring(DeviceCustomDate2Label), FlexDate1 = tostring(FlexDate1), FlexDate1Label = tostring(FlexDate1Label), FlexNumber1 = toint(FlexNumber1), DeviceCustomString6Label = tostring(DeviceCustomString6Label), SimplifiedDeviceAction = tostring(SimplifiedDeviceAction), SourceServiceName = tostring(SourceServiceName), SourceNTDomain = tostring(SourceNTDomain), DeviceNtDomain = tostring(DeviceNtDomain), DeviceOutboundInterface = tostring(DeviceOutboundInterface), DevicePayloadId = tostring(DevicePayloadId), ProcessName = tostring(ProcessName), DeviceTranslatedAddress = tostring(DeviceTranslatedAddress), DestinationHostName = tostring(DestinationHostName), DestinationMACAddress = tostring(DestinationMACAddress), DestinationNTDomain = tostring(DestinationNTDomain), DestinationProcessId = toint(DestinationProcessId), DestinationUserPrivileges = tostring(DestinationUserPrivileges), DestinationProcessName = tostring(DestinationProcessName), DestinationPort = toint(DestinationPort), DestinationIP = tostring(DestinationIP), DeviceTimeZone = tostring(DeviceTimeZone), DestinationUserID = tostring(DestinationUserID), DeviceInboundInterface = tostring(DeviceInboundInterface), DeviceFacility = tostring(DeviceFacility), DeviceExternalID = tostring(DeviceExternalID), DeviceDnsDomain = tostring(DeviceDnsDomain), DeviceVendor = tostring(DeviceVendor), DeviceProduct = tostring(DeviceProduct), DeviceVersion = tostring(DeviceVersion), DeviceEventClassID = tostring(DeviceEventClassID), Activity = tostring(Activity), LogSeverity = tostring(LogSeverity), OriginalLogSeverity = tostring(OriginalLogSeverity), DestinationUserName = tostring(DestinationUserName), AdditionalExtensions = tostring(AdditionalExtensions), ApplicationProtocol = tostring(ApplicationProtocol), EventCount = toint(EventCount), DestinationDnsDomain = tostring(DestinationDnsDomain), DestinationServiceName = tostring(DestinationServiceName), DestinationTranslatedAddress = tostring(DestinationTranslatedAddress), DestinationTranslatedPort = toint(DestinationTranslatedPort), CommunicationDirection = tostring(CommunicationDirection), DeviceAction = tostring(DeviceAction), DeviceAddress = tostring(DeviceAddress), DeviceName = tostring(DeviceName), DeviceMacAddress = tostring(DeviceMacAddress), OldFilePath = tostring(OldFilePath), OldFilePermission = tostring(OldFilePermission), OldFileSize = toint(OldFileSize), OldFileType = tostring(OldFileType), SentBytes = tolong(SentBytes), EventOutcome = tostring(EventOutcome), Protocol = tostring(Protocol), OldFileName = tostring(OldFileName), Reason = tostring(Reason), RequestClientApplication = tostring(RequestClientApplication), RequestContext = tostring(RequestContext), RequestCookies = tostring(RequestCookies), RequestMethod = tostring(RequestMethod), ReceiptTime = tostring(ReceiptTime), SourceHostName = tostring(SourceHostName), SourceMACAddress = tostring(SourceMACAddress), RequestURL = tostring(RequestURL), SourceDnsDomain = tostring(SourceDnsDomain), OldFileModificationTime = tostring(OldFileModificationTime), OldFileHash = tostring(OldFileHash), ProcessID = toint(ProcessID), EndTime = todatetime(EndTime), ExternalID = toint(ExternalID), ExtID = tostring(ExtID), FileCreateTime = tostring(FileCreateTime), FileHash = tostring(FileHash), FileID = tostring(FileID), OldFileID = tostring(OldFileID), FileModificationTime = tostring(FileModificationTime), FilePermission = tostring(FilePermission), FileType = tostring(FileType), FileName = tostring(FileName), FileSize = toint(FileSize), ReceivedBytes = tolong(ReceivedBytes), Message = tostring(Message), OldFileCreateTime = tostring(OldFileCreateTime), FilePath = tostring(FilePath), CollectorHostName = tostring(CollectorHostName)'
        outputStream: 'Microsoft-CommonSecurityLog'
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
