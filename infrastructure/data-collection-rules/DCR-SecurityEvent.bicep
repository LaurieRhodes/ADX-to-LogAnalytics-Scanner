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
// Data Collection Rule for SecurityEvent
// ============================================================================
// Generated: 2025-09-18 07:50:27
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 234, DCR columns: 232 (Type column always filtered)
// Input stream: Custom-SecurityEvent (always Custom- for JSON ingestion)
// Output stream: Microsoft-SecurityEvent (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-SecurityEvent'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-SecurityEvent': {
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
            name: 'PrimaryGroupId'
            type: 'string'
          }
          {
            name: 'PrivateKeyUsageCount'
            type: 'string'
          }
          {
            name: 'PrivilegeList'
            type: 'string'
          }
          {
            name: 'Process'
            type: 'string'
          }
          {
            name: 'ProcessId'
            type: 'string'
          }
          {
            name: 'ProcessName'
            type: 'string'
          }
          {
            name: 'Properties'
            type: 'string'
          }
          {
            name: 'ProfilePath'
            type: 'string'
          }
          {
            name: 'ProtocolSequence'
            type: 'string'
          }
          {
            name: 'ProxyPolicyName'
            type: 'string'
          }
          {
            name: 'QuarantineHelpURL'
            type: 'string'
          }
          {
            name: 'QuarantineSessionID'
            type: 'string'
          }
          {
            name: 'QuarantineSessionIdentifier'
            type: 'string'
          }
          {
            name: 'QuarantineState'
            type: 'string'
          }
          {
            name: 'QuarantineSystemHealthResult'
            type: 'string'
          }
          {
            name: 'RelativeTargetName'
            type: 'string'
          }
          {
            name: 'RemoteIpAddress'
            type: 'string'
          }
          {
            name: 'RemotePort'
            type: 'string'
          }
          {
            name: 'Requester'
            type: 'string'
          }
          {
            name: 'RequestId'
            type: 'string'
          }
          {
            name: 'RestrictedAdminMode'
            type: 'string'
          }
          {
            name: 'RowsDeleted'
            type: 'string'
          }
          {
            name: 'SamAccountName'
            type: 'string'
          }
          {
            name: 'ScriptPath'
            type: 'string'
          }
          {
            name: 'SecurityDescriptor'
            type: 'string'
          }
          {
            name: 'PreviousTime'
            type: 'string'
          }
          {
            name: 'ServiceAccount'
            type: 'string'
          }
          {
            name: 'PreviousDate'
            type: 'string'
          }
          {
            name: 'PasswordLastSet'
            type: 'string'
          }
          {
            name: 'NewDate'
            type: 'string'
          }
          {
            name: 'NewMaxUsers'
            type: 'string'
          }
          {
            name: 'NewProcessId'
            type: 'string'
          }
          {
            name: 'NewProcessName'
            type: 'string'
          }
          {
            name: 'NewRemark'
            type: 'string'
          }
          {
            name: 'NewShareFlags'
            type: 'string'
          }
          {
            name: 'NewTime'
            type: 'string'
          }
          {
            name: 'NewUacValue'
            type: 'string'
          }
          {
            name: 'NewValue'
            type: 'string'
          }
          {
            name: 'NewValueType'
            type: 'string'
          }
          {
            name: 'ObjectName'
            type: 'string'
          }
          {
            name: 'ObjectServer'
            type: 'string'
          }
          {
            name: 'ObjectType'
            type: 'string'
          }
          {
            name: 'ObjectValueName'
            type: 'string'
          }
          {
            name: 'OemInformation'
            type: 'string'
          }
          {
            name: 'OldMaxUsers'
            type: 'string'
          }
          {
            name: 'OldRemark'
            type: 'string'
          }
          {
            name: 'OldShareFlags'
            type: 'string'
          }
          {
            name: 'OldUacValue'
            type: 'string'
          }
          {
            name: 'OldValue'
            type: 'string'
          }
          {
            name: 'OldValueType'
            type: 'string'
          }
          {
            name: 'OperationType'
            type: 'string'
          }
          {
            name: 'PackageName'
            type: 'string'
          }
          {
            name: 'ParentProcessName'
            type: 'string'
          }
          {
            name: 'PasswordHistoryLength'
            type: 'string'
          }
          {
            name: 'PasswordProperties'
            type: 'string'
          }
          {
            name: 'NetworkPolicyName'
            type: 'string'
          }
          {
            name: 'ServiceFileName'
            type: 'string'
          }
          {
            name: 'ServiceStartType'
            type: 'string'
          }
          {
            name: 'TargetUser'
            type: 'string'
          }
          {
            name: 'TargetUserName'
            type: 'string'
          }
          {
            name: 'TargetUserSid'
            type: 'string'
          }
          {
            name: 'TemplateContent'
            type: 'string'
          }
          {
            name: 'TemplateDSObjectFQDN'
            type: 'string'
          }
          {
            name: 'TemplateInternalName'
            type: 'string'
          }
          {
            name: 'TemplateOID'
            type: 'string'
          }
          {
            name: 'TemplateSchemaVersion'
            type: 'string'
          }
          {
            name: 'TemplateVersion'
            type: 'string'
          }
          {
            name: 'TokenElevationType'
            type: 'string'
          }
          {
            name: 'TransmittedServices'
            type: 'string'
          }
          {
            name: 'UserAccountControl'
            type: 'string'
          }
          {
            name: 'UserParameters'
            type: 'string'
          }
          {
            name: 'UserPrincipalName'
            type: 'string'
          }
          {
            name: 'UserWorkstations'
            type: 'string'
          }
          {
            name: 'VirtualAccount'
            type: 'string'
          }
          {
            name: 'VendorIds'
            type: 'string'
          }
          {
            name: 'Workstation'
            type: 'string'
          }
          {
            name: 'WorkstationName'
            type: 'string'
          }
          {
            name: 'SystemUserId'
            type: 'string'
          }
          {
            name: 'Version'
            type: 'string'
          }
          {
            name: 'Opcode'
            type: 'string'
          }
          {
            name: 'Keywords'
            type: 'string'
          }
          {
            name: 'Correlation'
            type: 'string'
          }
          {
            name: 'SystemProcessId'
            type: 'string'
          }
          {
            name: 'TargetSid'
            type: 'string'
          }
          {
            name: 'ServiceName'
            type: 'string'
          }
          {
            name: 'TargetServerName'
            type: 'string'
          }
          {
            name: 'TargetOutboundDomainName'
            type: 'string'
          }
          {
            name: 'ServiceType'
            type: 'string'
          }
          {
            name: 'SessionName'
            type: 'string'
          }
          {
            name: 'ShareLocalPath'
            type: 'string'
          }
          {
            name: 'ShareName'
            type: 'string'
          }
          {
            name: 'SidHistory'
            type: 'string'
          }
          {
            name: 'Status'
            type: 'string'
          }
          {
            name: 'SubjectAccount'
            type: 'string'
          }
          {
            name: 'SubcategoryGuid'
            type: 'string'
          }
          {
            name: 'SubcategoryId'
            type: 'string'
          }
          {
            name: 'Subject'
            type: 'string'
          }
          {
            name: 'SubjectDomainName'
            type: 'string'
          }
          {
            name: 'SubjectKeyIdentifier'
            type: 'string'
          }
          {
            name: 'SubjectLogonId'
            type: 'string'
          }
          {
            name: 'SubjectMachineName'
            type: 'string'
          }
          {
            name: 'SubjectMachineSID'
            type: 'string'
          }
          {
            name: 'SubjectUserName'
            type: 'string'
          }
          {
            name: 'SubjectUserSid'
            type: 'string'
          }
          {
            name: 'SubStatus'
            type: 'string'
          }
          {
            name: 'TableId'
            type: 'string'
          }
          {
            name: 'TargetAccount'
            type: 'string'
          }
          {
            name: 'TargetDomainName'
            type: 'string'
          }
          {
            name: 'TargetInfo'
            type: 'string'
          }
          {
            name: 'TargetLinkedLogonId'
            type: 'string'
          }
          {
            name: 'TargetLogonGuid'
            type: 'string'
          }
          {
            name: 'TargetLogonId'
            type: 'string'
          }
          {
            name: 'TargetOutboundUserName'
            type: 'string'
          }
          {
            name: 'SystemThreadId'
            type: 'string'
          }
          {
            name: 'NASPortType'
            type: 'string'
          }
          {
            name: 'NASIPv6Address'
            type: 'string'
          }
          {
            name: 'AdditionalInfo'
            type: 'string'
          }
          {
            name: 'AdditionalInfo2'
            type: 'string'
          }
          {
            name: 'AllowedToDelegateTo'
            type: 'string'
          }
          {
            name: 'Attributes'
            type: 'string'
          }
          {
            name: 'AuditPolicyChanges'
            type: 'string'
          }
          {
            name: 'AuditsDiscarded'
            type: 'string'
          }
          {
            name: 'AuthenticationLevel'
            type: 'string'
          }
          {
            name: 'AuthenticationPackageName'
            type: 'string'
          }
          {
            name: 'AuthenticationProvider'
            type: 'string'
          }
          {
            name: 'AuthenticationServer'
            type: 'string'
          }
          {
            name: 'AuthenticationService'
            type: 'string'
          }
          {
            name: 'AuthenticationType'
            type: 'string'
          }
          {
            name: 'CACertificateHash'
            type: 'string'
          }
          {
            name: 'CalledStationID'
            type: 'string'
          }
          {
            name: 'CallerProcessId'
            type: 'string'
          }
          {
            name: 'CallerProcessName'
            type: 'string'
          }
          {
            name: 'CallingStationID'
            type: 'string'
          }
          {
            name: 'CAPublicKeyHash'
            type: 'string'
          }
          {
            name: 'CategoryId'
            type: 'string'
          }
          {
            name: 'CertificateDatabaseHash'
            type: 'string'
          }
          {
            name: 'ClassId'
            type: 'string'
          }
          {
            name: 'ClassName'
            type: 'string'
          }
          {
            name: 'ClientAddress'
            type: 'string'
          }
          {
            name: 'ClientIPAddress'
            type: 'string'
          }
          {
            name: 'ClientName'
            type: 'string'
          }
          {
            name: 'AccountSessionIdentifier'
            type: 'string'
          }
          {
            name: 'CommandLine'
            type: 'string'
          }
          {
            name: 'AccountName'
            type: 'string'
          }
          {
            name: 'AccountDomain'
            type: 'string'
          }
          {
            name: 'SourceSystem'
            type: 'string'
          }
          {
            name: 'Account'
            type: 'string'
          }
          {
            name: 'AccountType'
            type: 'string'
          }
          {
            name: 'Computer'
            type: 'string'
          }
          {
            name: 'EventSourceName'
            type: 'string'
          }
          {
            name: 'Channel'
            type: 'string'
          }
          {
            name: 'Task'
            type: 'string'
          }
          {
            name: 'Level'
            type: 'string'
          }
          {
            name: 'EventLevelName'
            type: 'string'
          }
          {
            name: 'EventData'
            type: 'string'
          }
          {
            name: 'EventID'
            type: 'string'
          }
          {
            name: 'Activity'
            type: 'string'
          }
          {
            name: 'SourceComputerId'
            type: 'string'
          }
          {
            name: 'EventOriginId'
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
            name: 'PartitionKey'
            type: 'string'
          }
          {
            name: 'RowKey'
            type: 'string'
          }
          {
            name: 'StorageAccount'
            type: 'string'
          }
          {
            name: 'AzureDeploymentID'
            type: 'string'
          }
          {
            name: 'AzureTableName'
            type: 'string'
          }
          {
            name: 'AccessList'
            type: 'string'
          }
          {
            name: 'AccessMask'
            type: 'string'
          }
          {
            name: 'AccessReason'
            type: 'string'
          }
          {
            name: 'AccountExpires'
            type: 'string'
          }
          {
            name: 'NASPort'
            type: 'string'
          }
          {
            name: 'CompatibleIds'
            type: 'string'
          }
          {
            name: 'DeviceDescription'
            type: 'string'
          }
          {
            name: 'KeyLength'
            type: 'string'
          }
          {
            name: 'LmPackageName'
            type: 'string'
          }
          {
            name: 'LocationInformation'
            type: 'string'
          }
          {
            name: 'LockoutDuration'
            type: 'string'
          }
          {
            name: 'LockoutObservationWindow'
            type: 'string'
          }
          {
            name: 'LockoutThreshold'
            type: 'string'
          }
          {
            name: 'LoggingResult'
            type: 'string'
          }
          {
            name: 'LogonGuid'
            type: 'string'
          }
          {
            name: 'LogonHours'
            type: 'string'
          }
          {
            name: 'LogonID'
            type: 'string'
          }
          {
            name: 'LogonProcessName'
            type: 'string'
          }
          {
            name: 'LogonType'
            type: 'string'
          }
          {
            name: 'LogonTypeName'
            type: 'string'
          }
          {
            name: 'MachineAccountQuota'
            type: 'string'
          }
          {
            name: 'MachineInventory'
            type: 'string'
          }
          {
            name: 'MachineLogon'
            type: 'string'
          }
          {
            name: 'MandatoryLabel'
            type: 'string'
          }
          {
            name: 'MaxPasswordAge'
            type: 'string'
          }
          {
            name: 'MemberName'
            type: 'string'
          }
          {
            name: 'MemberSid'
            type: 'string'
          }
          {
            name: 'MinPasswordAge'
            type: 'string'
          }
          {
            name: 'MinPasswordLength'
            type: 'string'
          }
          {
            name: 'MixedDomainMode'
            type: 'string'
          }
          {
            name: 'NASIdentifier'
            type: 'string'
          }
          {
            name: 'NASIPv4Address'
            type: 'string'
          }
          {
            name: 'IpPort'
            type: 'string'
          }
          {
            name: 'DCDNSName'
            type: 'string'
          }
          {
            name: 'IpAddress'
            type: 'string'
          }
          {
            name: 'ImpersonationLevel'
            type: 'string'
          }
          {
            name: 'DeviceId'
            type: 'string'
          }
          {
            name: 'DisplayName'
            type: 'string'
          }
          {
            name: 'Disposition'
            type: 'string'
          }
          {
            name: 'DomainBehaviorVersion'
            type: 'string'
          }
          {
            name: 'DomainName'
            type: 'string'
          }
          {
            name: 'DomainPolicyChanged'
            type: 'string'
          }
          {
            name: 'DomainSid'
            type: 'string'
          }
          {
            name: 'EAPType'
            type: 'string'
          }
          {
            name: 'ElevatedToken'
            type: 'string'
          }
          {
            name: 'ErrorCode'
            type: 'string'
          }
          {
            name: 'ExtendedQuarantineState'
            type: 'string'
          }
          {
            name: 'FailureReason'
            type: 'string'
          }
          {
            name: 'FileHash'
            type: 'string'
          }
          {
            name: 'FilePath'
            type: 'string'
          }
          {
            name: 'FilePathNoUser'
            type: 'string'
          }
          {
            name: 'Filter'
            type: 'string'
          }
          {
            name: 'ForceLogoff'
            type: 'string'
          }
          {
            name: 'Fqbn'
            type: 'string'
          }
          {
            name: 'FullyQualifiedSubjectMachineName'
            type: 'string'
          }
          {
            name: 'FullyQualifiedSubjectUserName'
            type: 'string'
          }
          {
            name: 'GroupMembership'
            type: 'string'
          }
          {
            name: 'HandleId'
            type: 'string'
          }
          {
            name: 'HardwareIds'
            type: 'string'
          }
          {
            name: 'HomeDirectory'
            type: 'string'
          }
          {
            name: 'HomePath'
            type: 'string'
          }
          {
            name: 'InterfaceUuid'
            type: 'string'
          }
          {
            name: 'EventRecordId'
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
          name: 'Sentinel-SecurityEvent'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-SecurityEvent']
        destinations: ['Sentinel-SecurityEvent']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), PrimaryGroupId = tostring(PrimaryGroupId), PrivateKeyUsageCount = tostring(PrivateKeyUsageCount), PrivilegeList = tostring(PrivilegeList), Process = tostring(Process), ProcessId = tostring(ProcessId), ProcessName = tostring(ProcessName), Properties = tostring(Properties), ProfilePath = tostring(ProfilePath), ProtocolSequence = tostring(ProtocolSequence), ProxyPolicyName = tostring(ProxyPolicyName), QuarantineHelpURL = tostring(QuarantineHelpURL), QuarantineSessionID = tostring(QuarantineSessionID), QuarantineSessionIdentifier = tostring(QuarantineSessionIdentifier), QuarantineState = tostring(QuarantineState), QuarantineSystemHealthResult = tostring(QuarantineSystemHealthResult), RelativeTargetName = tostring(RelativeTargetName), RemoteIpAddress = tostring(RemoteIpAddress), RemotePort = tostring(RemotePort), Requester = tostring(Requester), RequestId = tostring(RequestId), RestrictedAdminMode = tostring(RestrictedAdminMode), RowsDeleted = tostring(RowsDeleted), SamAccountName = tostring(SamAccountName), ScriptPath = tostring(ScriptPath), SecurityDescriptor = tostring(SecurityDescriptor), PreviousTime = tostring(PreviousTime), ServiceAccount = tostring(ServiceAccount), PreviousDate = tostring(PreviousDate), PasswordLastSet = tostring(PasswordLastSet), NewDate = tostring(NewDate), NewMaxUsers = tostring(NewMaxUsers), NewProcessId = tostring(NewProcessId), NewProcessName = tostring(NewProcessName), NewRemark = tostring(NewRemark), NewShareFlags = tostring(NewShareFlags), NewTime = tostring(NewTime), NewUacValue = tostring(NewUacValue), NewValue = tostring(NewValue), NewValueType = tostring(NewValueType), ObjectName = tostring(ObjectName), ObjectServer = tostring(ObjectServer), ObjectType = tostring(ObjectType), ObjectValueName = tostring(ObjectValueName), OemInformation = tostring(OemInformation), OldMaxUsers = tostring(OldMaxUsers), OldRemark = tostring(OldRemark), OldShareFlags = tostring(OldShareFlags), OldUacValue = tostring(OldUacValue), OldValue = tostring(OldValue), OldValueType = tostring(OldValueType), OperationType = tostring(OperationType), PackageName = tostring(PackageName), ParentProcessName = tostring(ParentProcessName), PasswordHistoryLength = tostring(PasswordHistoryLength), PasswordProperties = tostring(PasswordProperties), NetworkPolicyName = tostring(NetworkPolicyName), ServiceFileName = tostring(ServiceFileName), ServiceStartType = toint(ServiceStartType), TargetUser = tostring(TargetUser), TargetUserName = tostring(TargetUserName), TargetUserSid = tostring(TargetUserSid), TemplateContent = tostring(TemplateContent), TemplateDSObjectFQDN = tostring(TemplateDSObjectFQDN), TemplateInternalName = tostring(TemplateInternalName), TemplateOID = tostring(TemplateOID), TemplateSchemaVersion = tostring(TemplateSchemaVersion), TemplateVersion = tostring(TemplateVersion), TokenElevationType = tostring(TokenElevationType), TransmittedServices = tostring(TransmittedServices), UserAccountControl = tostring(UserAccountControl), UserParameters = tostring(UserParameters), UserPrincipalName = tostring(UserPrincipalName), UserWorkstations = tostring(UserWorkstations), VirtualAccount = tostring(VirtualAccount), VendorIds = tostring(VendorIds), Workstation = tostring(Workstation), WorkstationName = tostring(WorkstationName), SystemUserId = tostring(SystemUserId), Version = toint(Version), Opcode = tostring(Opcode), Keywords = tostring(Keywords), Correlation = tostring(Correlation), SystemProcessId = toint(SystemProcessId), TargetSid = tostring(TargetSid), ServiceName = tostring(ServiceName), TargetServerName = tostring(TargetServerName), TargetOutboundDomainName = tostring(TargetOutboundDomainName), ServiceType = tostring(ServiceType), SessionName = tostring(SessionName), ShareLocalPath = tostring(ShareLocalPath), ShareName = tostring(ShareName), SidHistory = tostring(SidHistory), Status = tostring(Status), SubjectAccount = tostring(SubjectAccount), SubcategoryGuid = toguid(SubcategoryGuid), SubcategoryId = tostring(SubcategoryId), Subject = tostring(Subject), SubjectDomainName = tostring(SubjectDomainName), SubjectKeyIdentifier = tostring(SubjectKeyIdentifier), SubjectLogonId = tostring(SubjectLogonId), SubjectMachineName = tostring(SubjectMachineName), SubjectMachineSID = tostring(SubjectMachineSID), SubjectUserName = tostring(SubjectUserName), SubjectUserSid = tostring(SubjectUserSid), SubStatus = tostring(SubStatus), TableId = tostring(TableId), TargetAccount = tostring(TargetAccount), TargetDomainName = tostring(TargetDomainName), TargetInfo = tostring(TargetInfo), TargetLinkedLogonId = tostring(TargetLinkedLogonId), TargetLogonGuid = toguid(TargetLogonGuid), TargetLogonId = tostring(TargetLogonId), TargetOutboundUserName = tostring(TargetOutboundUserName), SystemThreadId = toint(SystemThreadId), NASPortType = tostring(NASPortType), NASIPv6Address = tostring(NASIPv6Address), AdditionalInfo = tostring(AdditionalInfo), AdditionalInfo2 = tostring(AdditionalInfo2), AllowedToDelegateTo = tostring(AllowedToDelegateTo), Attributes = tostring(Attributes), AuditPolicyChanges = tostring(AuditPolicyChanges), AuditsDiscarded = toint(AuditsDiscarded), AuthenticationLevel = toint(AuthenticationLevel), AuthenticationPackageName = tostring(AuthenticationPackageName), AuthenticationProvider = tostring(AuthenticationProvider), AuthenticationServer = tostring(AuthenticationServer), AuthenticationService = toint(AuthenticationService), AuthenticationType = tostring(AuthenticationType), CACertificateHash = tostring(CACertificateHash), CalledStationID = tostring(CalledStationID), CallerProcessId = tostring(CallerProcessId), CallerProcessName = tostring(CallerProcessName), CallingStationID = tostring(CallingStationID), CAPublicKeyHash = tostring(CAPublicKeyHash), CategoryId = tostring(CategoryId), CertificateDatabaseHash = tostring(CertificateDatabaseHash), ClassId = tostring(ClassId), ClassName = tostring(ClassName), ClientAddress = tostring(ClientAddress), ClientIPAddress = tostring(ClientIPAddress), ClientName = tostring(ClientName), AccountSessionIdentifier = tostring(AccountSessionIdentifier), CommandLine = tostring(CommandLine), AccountName = tostring(AccountName), AccountDomain = tostring(AccountDomain), SourceSystem = tostring(SourceSystem), Account = tostring(Account), AccountType = tostring(AccountType), Computer = tostring(Computer), EventSourceName = tostring(EventSourceName), Channel = tostring(Channel), Task = toint(Task), Level = tostring(Level), EventLevelName = tostring(EventLevelName), EventData = tostring(EventData), EventID = toint(EventID), Activity = tostring(Activity), SourceComputerId = toguid(SourceComputerId), EventOriginId = tostring(EventOriginId), MG = toguid(MG), TimeCollected = todatetime(TimeCollected), ManagementGroupName = tostring(ManagementGroupName), PartitionKey = tostring(PartitionKey), RowKey = tostring(RowKey), StorageAccount = tostring(StorageAccount), AzureDeploymentID = tostring(AzureDeploymentID), AzureTableName = tostring(AzureTableName), AccessList = tostring(AccessList), AccessMask = tostring(AccessMask), AccessReason = tostring(AccessReason), AccountExpires = tostring(AccountExpires), NASPort = tostring(NASPort), CompatibleIds = tostring(CompatibleIds), DeviceDescription = tostring(DeviceDescription), KeyLength = toint(KeyLength), LmPackageName = tostring(LmPackageName), LocationInformation = tostring(LocationInformation), LockoutDuration = tostring(LockoutDuration), LockoutObservationWindow = tostring(LockoutObservationWindow), LockoutThreshold = tostring(LockoutThreshold), LoggingResult = tostring(LoggingResult), LogonGuid = toguid(LogonGuid), LogonHours = tostring(LogonHours), LogonID = tostring(LogonID), LogonProcessName = tostring(LogonProcessName), LogonType = toint(LogonType), LogonTypeName = tostring(LogonTypeName), MachineAccountQuota = tostring(MachineAccountQuota), MachineInventory = tostring(MachineInventory), MachineLogon = tostring(MachineLogon), MandatoryLabel = tostring(MandatoryLabel), MaxPasswordAge = tostring(MaxPasswordAge), MemberName = tostring(MemberName), MemberSid = tostring(MemberSid), MinPasswordAge = tostring(MinPasswordAge), MinPasswordLength = tostring(MinPasswordLength), MixedDomainMode = tostring(MixedDomainMode), NASIdentifier = tostring(NASIdentifier), NASIPv4Address = tostring(NASIPv4Address), IpPort = tostring(IpPort), DCDNSName = tostring(DCDNSName), IpAddress = tostring(IpAddress), ImpersonationLevel = tostring(ImpersonationLevel), DeviceId = tostring(DeviceId), DisplayName = tostring(DisplayName), Disposition = tostring(Disposition), DomainBehaviorVersion = tostring(DomainBehaviorVersion), DomainName = tostring(DomainName), DomainPolicyChanged = tostring(DomainPolicyChanged), DomainSid = tostring(DomainSid), EAPType = tostring(EAPType), ElevatedToken = tostring(ElevatedToken), ErrorCode = toint(ErrorCode), ExtendedQuarantineState = tostring(ExtendedQuarantineState), FailureReason = tostring(FailureReason), FileHash = tostring(FileHash), FilePath = tostring(FilePath), FilePathNoUser = tostring(FilePathNoUser), Filter = tostring(Filter), ForceLogoff = tostring(ForceLogoff), Fqbn = tostring(Fqbn), FullyQualifiedSubjectMachineName = tostring(FullyQualifiedSubjectMachineName), FullyQualifiedSubjectUserName = tostring(FullyQualifiedSubjectUserName), GroupMembership = tostring(GroupMembership), HandleId = tostring(HandleId), HardwareIds = tostring(HardwareIds), HomeDirectory = tostring(HomeDirectory), HomePath = tostring(HomePath), InterfaceUuid = toguid(InterfaceUuid), EventRecordId = tostring(EventRecordId)'
        outputStream: 'Microsoft-SecurityEvent'
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
