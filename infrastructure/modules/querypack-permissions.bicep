// Query Pack Permissions Module
// Assigns Log Analytics Contributor role to allow API access to Query Pack queries

targetScope = 'resourceGroup'

@description('Full resource ID of the Query Pack')
param queryPackResourceId string

@description('Principal ID of the managed identity')
param managedIdentityPrincipalId string

// Extract Query Pack name from the resource ID
var queryPackResourceParts = split(queryPackResourceId, '/')
var queryPackName = last(queryPackResourceParts)

// Log Analytics Contributor role - required for Query Pack API access
// Reader role only allows portal access, not REST API access
var logAnalyticsContributorRoleId = '92aaf0da-9dab-42b6-94a3-d43ce8d16293'
var logAnalyticsContributorRoleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', logAnalyticsContributorRoleId)

// Get existing Query Pack resource
resource queryPack 'Microsoft.OperationalInsights/queryPacks@2019-09-01' existing = {
  name: queryPackName
}

// Assign Log Analytics Contributor role on Query Pack resource
// This is required for REST API access to query pack queries
resource queryPackContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: queryPack
  name: guid(queryPack.id, logAnalyticsContributorRoleDefinitionResourceId, managedIdentityPrincipalId)
  properties: {
    roleDefinitionId: logAnalyticsContributorRoleDefinitionResourceId
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
    description: 'Grants Log Analytics Contributor access to Query Pack - required for REST API access to queries'
  }
}

// Outputs
output queryPackId string = queryPack.id
output queryPackName string = queryPack.name
output contributorRoleAssignmentId string = queryPackContributorRoleAssignment.id
output assignedRole object = {
  role: 'Log Analytics Contributor'
  roleDefinitionId: logAnalyticsContributorRoleId
  scope: 'QueryPack'
  assignmentId: queryPackContributorRoleAssignment.id
}
