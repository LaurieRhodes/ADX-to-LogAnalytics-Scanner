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
// Data Collection Rule for AWSCloudTrail
// ============================================================================
// Generated: 2025-09-18 07:50:15
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 51, DCR columns: 50 (Type column always filtered)
// Input stream: Custom-AWSCloudTrail (always Custom- for JSON ingestion)
// Output stream: Microsoft-AWSCloudTrail (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-AWSCloudTrail'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-AWSCloudTrail': {
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
            name: 'RequestParameters'
            type: 'string'
          }
          {
            name: 'ResponseElements'
            type: 'string'
          }
          {
            name: 'AdditionalEventData'
            type: 'string'
          }
          {
            name: 'AwsRequestId'
            type: 'string'
          }
          {
            name: 'AwsRequestId_'
            type: 'string'
          }
          {
            name: 'Resources'
            type: 'string'
          }
          {
            name: 'APIVersion'
            type: 'string'
          }
          {
            name: 'ReadOnly'
            type: 'string'
          }
          {
            name: 'RecipientAccountId'
            type: 'string'
          }
          {
            name: 'ServiceEventDetails'
            type: 'string'
          }
          {
            name: 'SharedEventId'
            type: 'string'
          }
          {
            name: 'VpcEndpointId'
            type: 'string'
          }
          {
            name: 'ManagementEvent'
            type: 'string'
          }
          {
            name: 'SourceSystem'
            type: 'string'
          }
          {
            name: 'OperationName'
            type: 'string'
          }
          {
            name: 'Category'
            type: 'string'
          }
          {
            name: 'TlsVersion'
            type: 'string'
          }
          {
            name: 'CipherSuite'
            type: 'string'
          }
          {
            name: 'ClientProvidedHostHeader'
            type: 'string'
          }
          {
            name: 'IpProtocol'
            type: 'string'
          }
          {
            name: 'SourcePort'
            type: 'string'
          }
          {
            name: 'ErrorMessage'
            type: 'string'
          }
          {
            name: 'DestinationPort'
            type: 'string'
          }
          {
            name: 'ErrorCode'
            type: 'string'
          }
          {
            name: 'SourceIpAddress'
            type: 'string'
          }
          {
            name: 'AwsEventId'
            type: 'string'
          }
          {
            name: 'EventVersion'
            type: 'string'
          }
          {
            name: 'EventSource'
            type: 'string'
          }
          {
            name: 'EventTypeName'
            type: 'string'
          }
          {
            name: 'EventName'
            type: 'string'
          }
          {
            name: 'UserIdentityType'
            type: 'string'
          }
          {
            name: 'UserIdentityPrincipalid'
            type: 'string'
          }
          {
            name: 'UserIdentityArn'
            type: 'string'
          }
          {
            name: 'UserIdentityAccountId'
            type: 'string'
          }
          {
            name: 'UserIdentityInvokedBy'
            type: 'string'
          }
          {
            name: 'UserIdentityAccessKeyId'
            type: 'string'
          }
          {
            name: 'UserIdentityUserName'
            type: 'string'
          }
          {
            name: 'SessionMfaAuthenticated'
            type: 'string'
          }
          {
            name: 'SessionCreationDate'
            type: 'string'
          }
          {
            name: 'SessionIssuerType'
            type: 'string'
          }
          {
            name: 'SessionIssuerPrincipalId'
            type: 'string'
          }
          {
            name: 'SessionIssuerArn'
            type: 'string'
          }
          {
            name: 'SessionIssuerAccountId'
            type: 'string'
          }
          {
            name: 'SessionIssuerUserName'
            type: 'string'
          }
          {
            name: 'EC2RoleDelivery'
            type: 'string'
          }
          {
            name: 'AWSRegion'
            type: 'string'
          }
          {
            name: 'UserAgent'
            type: 'string'
          }
          {
            name: 'CidrIp'
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
          name: 'Sentinel-AWSCloudTrail'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-AWSCloudTrail']
        destinations: ['Sentinel-AWSCloudTrail']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), RequestParameters = tostring(RequestParameters), ResponseElements = tostring(ResponseElements), AdditionalEventData = tostring(AdditionalEventData), AwsRequestId = toguid(AwsRequestId), AwsRequestId_ = tostring(AwsRequestId_), Resources = tostring(Resources), APIVersion = tostring(APIVersion), ReadOnly = tobool(ReadOnly), RecipientAccountId = tostring(RecipientAccountId), ServiceEventDetails = tostring(ServiceEventDetails), SharedEventId = toguid(SharedEventId), VpcEndpointId = tostring(VpcEndpointId), ManagementEvent = tobool(ManagementEvent), SourceSystem = tostring(SourceSystem), OperationName = tostring(OperationName), Category = tostring(Category), TlsVersion = tostring(TlsVersion), CipherSuite = tostring(CipherSuite), ClientProvidedHostHeader = tostring(ClientProvidedHostHeader), IpProtocol = tostring(IpProtocol), SourcePort = tostring(SourcePort), ErrorMessage = tostring(ErrorMessage), DestinationPort = tostring(DestinationPort), ErrorCode = tostring(ErrorCode), SourceIpAddress = tostring(SourceIpAddress), AwsEventId = toguid(AwsEventId), EventVersion = tostring(EventVersion), EventSource = tostring(EventSource), EventTypeName = tostring(EventTypeName), EventName = tostring(EventName), UserIdentityType = tostring(UserIdentityType), UserIdentityPrincipalid = tostring(UserIdentityPrincipalid), UserIdentityArn = tostring(UserIdentityArn), UserIdentityAccountId = tostring(UserIdentityAccountId), UserIdentityInvokedBy = tostring(UserIdentityInvokedBy), UserIdentityAccessKeyId = tostring(UserIdentityAccessKeyId), UserIdentityUserName = tostring(UserIdentityUserName), SessionMfaAuthenticated = tobool(SessionMfaAuthenticated), SessionCreationDate = todatetime(SessionCreationDate), SessionIssuerType = tostring(SessionIssuerType), SessionIssuerPrincipalId = tostring(SessionIssuerPrincipalId), SessionIssuerArn = tostring(SessionIssuerArn), SessionIssuerAccountId = tostring(SessionIssuerAccountId), SessionIssuerUserName = tostring(SessionIssuerUserName), EC2RoleDelivery = tostring(EC2RoleDelivery), AWSRegion = tostring(AWSRegion), UserAgent = tostring(UserAgent), CidrIp = tostring(CidrIp)'
        outputStream: 'Microsoft-AWSCloudTrail'
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
