//Retrieves a built in role definition GUID using PowerShell

@description('Name of the RBAC role to decode')
param builtInRoleName string
@description('Azure Region for deployment')
param azRegion string = resourceGroup().location
@description('ID of the user assigned identity')
param userAssignedIdentityID string

var uaiObject = length(userAssignedIdentityID) > 0  ? {
      '${userAssignedIdentityID}': {}
    } : {}

//NOTE: Cannot use ${$var} syntax since bicep/arm (I believe) interprets it
var script = '''
param([string] $DefName)
$def = Get-AzRoleDefinition -Name $DefName
$ID = $Def.ID
Write-Host "Found ID: '$ID' for name: '$DefName'"
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs["GUID"] = $ID
'''

//Deployment script
resource ps 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind: 'AzurePowerShell'
  name: 'PSRoleDef-NameToGUID'
  location: azRegion
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: uaiObject
  }
  properties: {
    retentionInterval: 'PT1H'     //1 hour script object retention
    azPowerShellVersion: '5.0'    //
    arguments: '-DefName \\"${builtInRoleName}\\"'
    scriptContent: script
    timeout: 'PT5M'               //Set this longer for long running scripts.
    cleanupPreference: 'Always'   //Removes the ACI and Storageaccount when completed
  }
}

@description('GUID for the specified RBAC Role')
output GUID string = ps.properties.outputs.GUID
