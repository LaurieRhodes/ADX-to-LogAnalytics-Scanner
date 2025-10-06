// Event Hub Permissions Module
// Assigns Azure Event Hubs Data Sender role to managed identity
// FIXED: Now accepts full Event Hub Resource ID to support cross-subscription/resource-group scenarios

param eventHubResourceId string
param managedIdentityPrincipalId string

// Define Event Hubs Data Sender role ID
var eventHubDataSenderRoleId = '2b629674-e913-4c01-ae53-ef4638d8f975'
var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', eventHubDataSenderRoleId)

// Parse Event Hub Resource ID components for outputs
// Expected format: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.EventHub/namespaces/{namespace}/eventhubs/{eventhub}
var eventHubResourceIdParts = split(eventHubResourceId, '/')
var eventHubNamespace = eventHubResourceIdParts[8]
var eventHubName = eventHubResourceIdParts[10]

// Reference existing Event Hub Namespace in its actual subscription and resource group
// Note: This uses the 'existing' keyword which doesn't require scope matching
resource eventHubNamespaceResource 'Microsoft.EventHub/namespaces@2021-11-01' existing = {
  name: eventHubNamespace
}

// Reference existing Event Hub
resource eventHubResource 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' existing = {
  parent: eventHubNamespaceResource
  name: eventHubName
}

// Assign Azure Event Hubs Data Sender role to the managed identity at Event Hub level
resource eventHubRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: eventHubResource
  name: guid(eventHubResource.id, roleDefinitionResourceId, managedIdentityPrincipalId)
  properties: {
    roleDefinitionId: roleDefinitionResourceId
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output roleAssignmentId string = eventHubRoleAssignment.id
output roleAssignmentName string = eventHubRoleAssignment.name
output eventHubResourceId string = eventHubResource.id
output eventHubNamespace string = eventHubNamespace
output eventHubName string = eventHubName
