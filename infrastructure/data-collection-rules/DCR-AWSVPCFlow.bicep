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
// Data Collection Rule for AWSVPCFlow
// ============================================================================
// Generated: 2025-09-18 07:50:20
// Table type: Microsoft
// Schema discovered using hybrid approach (Management API + getschema)
// Underscore columns filtered out
// Original columns: 43, DCR columns: 42 (Type column always filtered)
// Input stream: Custom-AWSVPCFlow (always Custom- for JSON ingestion)
// Output stream: Microsoft-AWSVPCFlow (based on table type)
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-AWSVPCFlow'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-AWSVPCFlow': {
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
            name: 'AzId'
            type: 'string'
          }
          {
            name: 'SublocationType'
            type: 'string'
          }
          {
            name: 'SublocationId'
            type: 'string'
          }
          {
            name: 'PktSrcAwsService'
            type: 'string'
          }
          {
            name: 'PktDstAwsService'
            type: 'string'
          }
          {
            name: 'FlowDirection'
            type: 'string'
          }
          {
            name: 'TrafficPath'
            type: 'string'
          }
          {
            name: 'Start'
            type: 'string'
          }
          {
            name: 'EcsClusterArn'
            type: 'string'
          }
          {
            name: 'EcsClusterName'
            type: 'string'
          }
          {
            name: 'EcsContainerInstanceArn'
            type: 'string'
          }
          {
            name: 'EcsContainerInstanceId'
            type: 'string'
          }
          {
            name: 'EcsContainerId'
            type: 'string'
          }
          {
            name: 'EcsSecondContainerId'
            type: 'string'
          }
          {
            name: 'EcsServiceName'
            type: 'string'
          }
          {
            name: 'EcsTaskDefinitionArn'
            type: 'string'
          }
          {
            name: 'EcsTaskArn'
            type: 'string'
          }
          {
            name: 'Region'
            type: 'string'
          }
          {
            name: 'EcsTaskId'
            type: 'string'
          }
          {
            name: 'PktDstAddr'
            type: 'string'
          }
          {
            name: 'TrafficType'
            type: 'string'
          }
          {
            name: 'Version'
            type: 'string'
          }
          {
            name: 'AccountId'
            type: 'string'
          }
          {
            name: 'InterfaceId'
            type: 'string'
          }
          {
            name: 'SrcAddr'
            type: 'string'
          }
          {
            name: 'DstAddr'
            type: 'string'
          }
          {
            name: 'SrcPort'
            type: 'string'
          }
          {
            name: 'DstPort'
            type: 'string'
          }
          {
            name: 'Protocol'
            type: 'string'
          }
          {
            name: 'Packets'
            type: 'string'
          }
          {
            name: 'Bytes'
            type: 'string'
          }
          {
            name: 'End'
            type: 'string'
          }
          {
            name: 'Action'
            type: 'string'
          }
          {
            name: 'LogStatus'
            type: 'string'
          }
          {
            name: 'VpcId'
            type: 'string'
          }
          {
            name: 'SubnetId'
            type: 'string'
          }
          {
            name: 'InstanceId'
            type: 'string'
          }
          {
            name: 'TcpFlags'
            type: 'string'
          }
          {
            name: 'PktSrcAddr'
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
          name: 'Sentinel-AWSVPCFlow'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-AWSVPCFlow']
        destinations: ['Sentinel-AWSVPCFlow']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), AzId = tostring(AzId), SublocationType = tostring(SublocationType), SublocationId = tostring(SublocationId), PktSrcAwsService = tostring(PktSrcAwsService), PktDstAwsService = tostring(PktDstAwsService), FlowDirection = tostring(FlowDirection), TrafficPath = tostring(TrafficPath), Start = todatetime(Start), EcsClusterArn = tostring(EcsClusterArn), EcsClusterName = tostring(EcsClusterName), EcsContainerInstanceArn = tostring(EcsContainerInstanceArn), EcsContainerInstanceId = tostring(EcsContainerInstanceId), EcsContainerId = tostring(EcsContainerId), EcsSecondContainerId = tostring(EcsSecondContainerId), EcsServiceName = tostring(EcsServiceName), EcsTaskDefinitionArn = tostring(EcsTaskDefinitionArn), EcsTaskArn = tostring(EcsTaskArn), Region = tostring(Region), EcsTaskId = tostring(EcsTaskId), PktDstAddr = tostring(PktDstAddr), TrafficType = tostring(TrafficType), Version = toint(Version), AccountId = tostring(AccountId), InterfaceId = tostring(InterfaceId), SrcAddr = tostring(SrcAddr), DstAddr = tostring(DstAddr), SrcPort = toint(SrcPort), DstPort = toint(DstPort), Protocol = toint(Protocol), Packets = toint(Packets), Bytes = tolong(Bytes), End = todatetime(End), Action = tostring(Action), LogStatus = tostring(LogStatus), VpcId = tostring(VpcId), SubnetId = tostring(SubnetId), InstanceId = tostring(InstanceId), TcpFlags = toint(TcpFlags), PktSrcAddr = tostring(PktSrcAddr), SourceSystem = tostring(SourceSystem)'
        outputStream: 'Microsoft-AWSVPCFlow'
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
