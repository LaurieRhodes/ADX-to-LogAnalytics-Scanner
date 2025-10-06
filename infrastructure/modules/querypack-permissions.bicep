// Query Pack Permissions Module
// This module handles Query Pack permissions for reading queries via REST API
// IMPORTANT: Query Packs require Resource Group level Reader permissions for REST API access

targetScope = 'resourceGroup'

@description('Full resource ID of the Query Pack')
param queryPackResourceId string

@description('Principal ID of the managed identity')
param managedIdentityPrincipalId string

// Extract Query Pack name from the resource ID
var queryPackResourceParts = split(queryPackResourceId, '/')
var queryPackName = last(queryPackResourceParts)

// Define role definition IDs
var logAnalyticsReaderRoleId = '73c42c96-874c-492b-b04d-ab87d138a893'
var logAnalyticsReaderRoleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', logAnalyticsReaderRoleId)

var readerRoleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var readerRoleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', readerRoleId)

// Get existing Query Pack resource
resource queryPack 'Microsoft.OperationalInsights/queryPacks@2019-09-01' existing = {
  name: queryPackName
}

// CRITICAL: Assign Reader role at RESOURCE GROUP level
// Query Pack REST API access requires this broader scope
resource resourceGroupReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, readerRoleDefinitionResourceId, managedIdentityPrincipalId, 'querypack-rg-reader')
  properties: {
    roleDefinitionId: readerRoleDefinitionResourceId
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
    description: 'Grants Reader access at Resource Group level for Query Pack REST API access'
  }
}

// Also assign Log Analytics Reader on the Query Pack resource itself (defense in depth)
resource queryPackReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: queryPack
  name: guid(queryPack.id, logAnalyticsReaderRoleDefinitionResourceId, managedIdentityPrincipalId)
  properties: {
    roleDefinitionId: logAnalyticsReaderRoleDefinitionResourceId
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
    description: 'Grants Log Analytics Reader access to Query Pack resource'
  }
}

// Also assign Reader role at Query Pack resource level (belt and suspenders)
resource queryPackGeneralReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: queryPack
  name: guid(queryPack.id, readerRoleDefinitionResourceId, managedIdentityPrincipalId)
  properties: {
    roleDefinitionId: readerRoleDefinitionResourceId
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
    description: 'Grants Reader access to Query Pack resource'
  }
}

// Outputs
output queryPackId string = queryPack.id
output queryPackName string = queryPack.name
output resourceGroupReaderRoleAssignmentId string = resourceGroupReaderRoleAssignment.id
output logAnalyticsReaderRoleAssignmentId string = queryPackReaderRoleAssignment.id
output queryPackReaderRoleAssignmentId string = queryPackGeneralReaderRoleAssignment.id
output assignedRoles array = [
  {
    role: 'Reader (Resource Group)'
    roleDefinitionId: readerRoleId
    scope: 'ResourceGroup'
    assignmentId: resourceGroupReaderRoleAssignment.id
  }
  {
    role: 'Log Analytics Reader (Query Pack)'
    roleDefinitionId: logAnalyticsReaderRoleId
    scope: 'QueryPack'
    assignmentId: queryPackReaderRoleAssignment.id
  }
  {
    role: 'Reader (Query Pack)'
    roleDefinitionId: readerRoleId
    scope: 'QueryPack'
    assignmentId: queryPackGeneralReaderRoleAssignment.id
  }
]
