@description('Name of the user assigned identity')
param userAssignedIdentityName string

@description('Azure Region for deployment')
param azRegion string = resourceGroup().location

//Create UAI
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: userAssignedIdentityName
  location: azRegion
}

//Reader GUID - note the irony that we hard code the READER role's GUID in order to
// create a script to translate role names to GUIDs
var roleDefGUID = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
resource roleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: roleDefGUID
  scope: subscription()
}

//Adds reader role to the UAI for this RG
resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(userAssignedIdentity.id, resourceGroup().id, roleDefGUID)
  scope: resourceGroup()
  properties: {
    principalId: userAssignedIdentity.properties.principalId
    roleDefinitionId: roleDef.id
    principalType: 'ServicePrincipal'
  }
}

@description('Returns User Assigned Identity ID')
output id string = userAssignedIdentity.id
