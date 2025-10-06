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
// Data Collection Rule for GCP_DNS_CL
// ============================================================================
// Generated: 2025-09-18 08:37:30
// Table type: Custom (presumed custom for JSON exports)
// Schema imported from JSON export file
// Underscore columns filtered out
// Original columns: 45, DCR columns: 43 (Type column always filtered)
// Output stream: Custom-GCP_DNS_CL
// Note: Input stream uses string/dynamic only. Type conversions in transform.
// ============================================================================

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-${workspaceName}-GCP_DNS_CL'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-GCP_DNS_CL': {
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
            name: 'resource_labels_project_id_s'
            type: 'string'
          }
          {
            name: 'resource_labels_target_type_s'
            type: 'string'
          }
          {
            name: 'resource_labels_source_type_s'
            type: 'string'
          }
          {
            name: 'resource_labels_target_name_s'
            type: 'string'
          }
          {
            name: 'resource_labels_location_s'
            type: 'string'
          }
          {
            name: 'payload_vmProjectId_s'
            type: 'string'
          }
          {
            name: 'payload_protocol_s'
            type: 'string'
          }
          {
            name: 'payload_queryType_s'
            type: 'string'
          }
          {
            name: 'payload_rdata_s'
            type: 'string'
          }
          {
            name: 'payload_vmInstanceId_d'
            type: 'string'
          }
          {
            name: 'payload_vmInstanceIdString_s'
            type: 'string'
          }
          {
            name: 'payload_vmInstanceName_s'
            type: 'string'
          }
          {
            name: 'payload_responseCode_s'
            type: 'string'
          }
          {
            name: 'payload_authAnswer_b'
            type: 'string'
          }
          {
            name: 'payload_queryName_s'
            type: 'string'
          }
          {
            name: 'payload_vmZoneName_s'
            type: 'string'
          }
          {
            name: 'payload_sourceNetwork_s'
            type: 'string'
          }
          {
            name: 'resource_type_s'
            type: 'string'
          }
          {
            name: 'timestamp_t'
            type: 'string'
          }
          {
            name: 'severity_s'
            type: 'string'
          }
          {
            name: 'insert_id_s'
            type: 'string'
          }
          {
            name: 'SourceSystem'
            type: 'string'
          }
          {
            name: 'MG'
            type: 'string'
          }
          {
            name: 'ManagementGroupName'
            type: 'string'
          }
          {
            name: 'Computer'
            type: 'string'
          }
          {
            name: 'RawData'
            type: 'string'
          }
          {
            name: 'resource_labels_zone_name_s'
            type: 'string'
          }
          {
            name: 'payload__type_s'
            type: 'string'
          }
          {
            name: 'payload_authenticationInfo_principalEmail_s'
            type: 'string'
          }
          {
            name: 'payload_serverLatency_d'
            type: 'string'
          }
          {
            name: 'payload_requestMetadata_requestAttributes_time_t'
            type: 'string'
          }
          {
            name: 'payload_methodName_s'
            type: 'string'
          }
          {
            name: 'payload_authorizationInfo_s'
            type: 'string'
          }
          {
            name: 'payload_resourceName_s'
            type: 'string'
          }
          {
            name: 'payload_request__type_s'
            type: 'string'
          }
          {
            name: 'payload_request_project_s'
            type: 'string'
          }
          {
            name: 'resource_labels_policy_name_s'
            type: 'string'
          }
          {
            name: 'payload_request_managedZone_s'
            type: 'string'
          }
          {
            name: 'log_name_s'
            type: 'string'
          }
          {
            name: 'payload_serviceName_s'
            type: 'string'
          }
          {
            name: 'payload_sourceIP_s'
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
          name: 'Sentinel-GCP_DNS_CL'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-GCP_DNS_CL']
        destinations: ['Sentinel-GCP_DNS_CL']
        transformKql: 'source | project TimeGenerated = todatetime(TimeGenerated), TenantId = toguid(TenantId), resource_labels_project_id_s = tostring(resource_labels_project_id_s), resource_labels_target_type_s = tostring(resource_labels_target_type_s), resource_labels_source_type_s = tostring(resource_labels_source_type_s), resource_labels_target_name_s = tostring(resource_labels_target_name_s), resource_labels_location_s = tostring(resource_labels_location_s), payload_vmProjectId_s = tostring(payload_vmProjectId_s), payload_protocol_s = tostring(payload_protocol_s), payload_queryType_s = tostring(payload_queryType_s), payload_rdata_s = tostring(payload_rdata_s), payload_vmInstanceId_d = toreal(payload_vmInstanceId_d), payload_vmInstanceIdString_s = tostring(payload_vmInstanceIdString_s), payload_vmInstanceName_s = tostring(payload_vmInstanceName_s), payload_responseCode_s = tostring(payload_responseCode_s), payload_authAnswer_b = tobool(payload_authAnswer_b), payload_queryName_s = tostring(payload_queryName_s), payload_vmZoneName_s = tostring(payload_vmZoneName_s), payload_sourceNetwork_s = tostring(payload_sourceNetwork_s), resource_type_s = tostring(resource_type_s), timestamp_t = todatetime(timestamp_t), severity_s = tostring(severity_s), insert_id_s = tostring(insert_id_s), SourceSystem = tostring(SourceSystem), MG = tostring(MG), ManagementGroupName = tostring(ManagementGroupName), Computer = tostring(Computer), RawData = tostring(RawData), resource_labels_zone_name_s = tostring(resource_labels_zone_name_s), payload__type_s = tostring(payload__type_s), payload_authenticationInfo_principalEmail_s = tostring(payload_authenticationInfo_principalEmail_s), payload_serverLatency_d = toreal(payload_serverLatency_d), payload_requestMetadata_requestAttributes_time_t = todatetime(payload_requestMetadata_requestAttributes_time_t), payload_methodName_s = tostring(payload_methodName_s), payload_authorizationInfo_s = tostring(payload_authorizationInfo_s), payload_resourceName_s = tostring(payload_resourceName_s), payload_request__type_s = tostring(payload_request__type_s), payload_request_project_s = tostring(payload_request_project_s), resource_labels_policy_name_s = tostring(resource_labels_policy_name_s), payload_request_managedZone_s = tostring(payload_request_managedZone_s), log_name_s = tostring(log_name_s), payload_serviceName_s = tostring(payload_serviceName_s), payload_sourceIP_s = tostring(payload_sourceIP_s)'
        outputStream: 'Custom-GCP_DNS_CL'
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
