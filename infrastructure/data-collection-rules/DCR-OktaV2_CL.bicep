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
// Data Collection Rule for OktaV2_CL
// ============================================================================
// Generated: 2025-09-18 08:37:34
// Table type: Custom (presumed custom for JSON exports)
// Schema imported from JSON export file
// Underscore columns filtered out
// Original columns: 60, DCR columns: 59 (Type column always filtered)
// Output stream: Custom-OktaV2_CL
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-OktaV2_CL'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-OktaV2_CL': {
        columns: [
          {
            name: 'TimeGenerated'
            type: 'string'
          }
          {
            name: 'ActingAppName'
            type: 'string'
          }
          {
            name: 'OriginalSeverity'
            type: 'string'
          }
          {
            name: 'OriginalTarget'
            type: 'dynamic'
          }
          {
            name: 'OriginalUserId'
            type: 'string'
          }
          {
            name: 'OriginalUserType'
            type: 'string'
          }
          {
            name: 'Request'
            type: 'dynamic'
          }
          {
            name: 'SecurityContextAsNumber'
            type: 'string'
          }
          {
            name: 'SecurityContextAsOrg'
            type: 'string'
          }
          {
            name: 'SecurityContextDomain'
            type: 'string'
          }
          {
            name: 'SecurityContextIsProxy'
            type: 'string'
          }
          {
            name: 'SrcDeviceType'
            type: 'string'
          }
          {
            name: 'SrcDvcId'
            type: 'string'
          }
          {
            name: 'SrcDvcOs'
            type: 'string'
          }
          {
            name: 'SrcGeoCity'
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
            name: 'SrcGeoLongitude'
            type: 'string'
          }
          {
            name: 'SrcGeoPostalCode'
            type: 'string'
          }
          {
            name: 'SrcGeoRegion'
            type: 'string'
          }
          {
            name: 'SrcIpAddr'
            type: 'string'
          }
          {
            name: 'SrcIsp'
            type: 'string'
          }
          {
            name: 'SrcZone'
            type: 'string'
          }
          {
            name: 'TransactionDetail'
            type: 'dynamic'
          }
          {
            name: 'TransactionId'
            type: 'string'
          }
          {
            name: 'TransactionType'
            type: 'string'
          }
          {
            name: 'Version'
            type: 'string'
          }
          {
            name: 'OriginalOutcomeResult'
            type: 'string'
          }
          {
            name: 'OriginalClientDevice'
            type: 'string'
          }
          {
            name: 'OriginalActorAlternateId'
            type: 'string'
          }
          {
            name: 'LogonMethod'
            type: 'string'
          }
          {
            name: 'ActingAppType'
            type: 'string'
          }
          {
            name: 'ActorDetailEntry'
            type: 'dynamic'
          }
          {
            name: 'ActorDisplayName'
            type: 'string'
          }
          {
            name: 'ActorSessionId'
            type: 'string'
          }
          {
            name: 'ActorUserId'
            type: 'string'
          }
          {
            name: 'ActorUserIdType'
            type: 'string'
          }
          {
            name: 'ActorUsername'
            type: 'string'
          }
          {
            name: 'ActorUsernameType'
            type: 'string'
          }
          {
            name: 'ActorUserType'
            type: 'string'
          }
          {
            name: 'AuthenticationContextAuthenticationProvider'
            type: 'string'
          }
          {
            name: 'AuthenticationContextAuthenticationStep'
            type: 'string'
          }
          {
            name: 'AuthenticationContextCredentialProvider'
            type: 'string'
          }
          {
            name: 'SrcDvcIdType'
            type: 'string'
          }
          {
            name: 'AuthenticationContextInterface'
            type: 'string'
          }
          {
            name: 'AuthenticationContextIssuerType'
            type: 'string'
          }
          {
            name: 'DebugData'
            type: 'dynamic'
          }
          {
            name: 'DomainName'
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
            name: 'EventOriginalResultDetails'
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
            name: 'EventResult'
            type: 'string'
          }
          {
            name: 'EventSeverity'
            type: 'string'
          }
          {
            name: 'HttpUserAgent'
            type: 'string'
          }
          {
            name: 'LegacyEventType'
            type: 'string'
          }
          {
            name: 'AuthenticationContextIssuerId'
            type: 'string'
          }
          {
            name: 'TenantId'
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
          name: 'Sentinel-OktaV2_CL'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-OktaV2_CL']
        destinations: ['Sentinel-OktaV2_CL']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), ActingAppName = tostring(ActingAppName), OriginalSeverity = tostring(OriginalSeverity), OriginalTarget = todynamic(OriginalTarget), OriginalUserId = tostring(OriginalUserId), OriginalUserType = tostring(OriginalUserType), Request = todynamic(Request), SecurityContextAsNumber = toint(SecurityContextAsNumber), SecurityContextAsOrg = tostring(SecurityContextAsOrg), SecurityContextDomain = tostring(SecurityContextDomain), SecurityContextIsProxy = tobool(SecurityContextIsProxy), SrcDeviceType = tostring(SrcDeviceType), SrcDvcId = tostring(SrcDvcId), SrcDvcOs = tostring(SrcDvcOs), SrcGeoCity = tostring(SrcGeoCity), SrcGeoCountry = tostring(SrcGeoCountry), SrcGeoLatitude = toreal(SrcGeoLatitude), SrcGeoLongitude = toreal(SrcGeoLongitude), SrcGeoPostalCode = tostring(SrcGeoPostalCode), SrcGeoRegion = tostring(SrcGeoRegion), SrcIpAddr = tostring(SrcIpAddr), SrcIsp = tostring(SrcIsp), SrcZone = tostring(SrcZone), TransactionDetail = todynamic(TransactionDetail), TransactionId = tostring(TransactionId), TransactionType = tostring(TransactionType), Version = tostring(Version), OriginalOutcomeResult = tostring(OriginalOutcomeResult), OriginalClientDevice = tostring(OriginalClientDevice), OriginalActorAlternateId = tostring(OriginalActorAlternateId), LogonMethod = tostring(LogonMethod), ActingAppType = tostring(ActingAppType), ActorDetailEntry = todynamic(ActorDetailEntry), ActorDisplayName = tostring(ActorDisplayName), ActorSessionId = tostring(ActorSessionId), ActorUserId = tostring(ActorUserId), ActorUserIdType = tostring(ActorUserIdType), ActorUsername = tostring(ActorUsername), ActorUsernameType = tostring(ActorUsernameType), ActorUserType = tostring(ActorUserType), AuthenticationContextAuthenticationProvider = tostring(AuthenticationContextAuthenticationProvider), AuthenticationContextAuthenticationStep = toint(AuthenticationContextAuthenticationStep), AuthenticationContextCredentialProvider = tostring(AuthenticationContextCredentialProvider), SrcDvcIdType = tostring(SrcDvcIdType), AuthenticationContextInterface = tostring(AuthenticationContextInterface), AuthenticationContextIssuerType = tostring(AuthenticationContextIssuerType), DebugData = todynamic(DebugData), DomainName = tostring(DomainName), DvcAction = tostring(DvcAction), EventMessage = tostring(EventMessage), EventOriginalResultDetails = tostring(EventOriginalResultDetails), EventOriginalType = tostring(EventOriginalType), EventOriginalUid = tostring(EventOriginalUid), EventResult = tostring(EventResult), EventSeverity = tostring(EventSeverity), HttpUserAgent = tostring(HttpUserAgent), LegacyEventType = tostring(LegacyEventType), AuthenticationContextIssuerId = tostring(AuthenticationContextIssuerId), TenantId = toguid(TenantId)'
        outputStream: 'Custom-OktaV2_CL'
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
