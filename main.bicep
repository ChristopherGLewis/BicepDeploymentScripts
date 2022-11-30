targetScope = 'subscription'

@description('Resource Group name')
param rgName string

@description('Azure region for deployment')
param azRegion string

@description('User Assigned Identity name')
param userAssignedIdentityName string = 'DeploymentScriptUAI'

@description('RBAC Role name')
param roleName string

//Create our RG
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: azRegion
}

//Make our UAI for roleDef
module uai './Modules/userassignedidentity.bicep' = {
  name: 'uai'
  scope: rg
  params: {
    userAssignedIdentityName: userAssignedIdentityName
    azRegion: azRegion
  }
}

//Get our GUID for the specified role name
module roleDef './Modules/roledefguid.bicep' = {
  name: 'roleDef'
  scope: rg
  params: {
    azRegion: azRegion
    builtInRoleName: roleName
    userAssignedIdentityID: uai.outputs.id
  }
}

@description('GUID of the specified role')
output GUID string = roleDef.outputs.GUID
