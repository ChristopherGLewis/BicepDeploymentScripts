# Bicep Deployment Scripts

Demo of Deployment Scripts in Bicep

## Introduction

This project demonstrates how to use DeploymentScripts to manipulate Azure objects
that are not exposed in ARM.  Deployment script are PowerShell or sh scripts that
are run inside a scripting environment created via an ephemeral Azure Container
Instance.

Note: DeploymentScripts without the User Assigned Identity (UAI) are *very* functionally
limited.  You certainly can pass in user/password values to the script, but I don't
believe there's any way to send these in a secure fashion and these would then be
exposed in the portal's deployment history.

## modules

There are two main modules that are used in the Role Definition GUID main.bicep

* userassignedidentiy.bicep

  This module creates the UAI and grants it the READER role for this resource
  group.  This is necessary to allow the deployment script to run the PowerShell
  script using Az-Connect.

* roledefguid.bicep

  This module creates the DeploymentScript for determining the role's GUID.
  it takes the UAI's ID from the above module and uses it to run the following
  script:

    ``` PowerShell
    param([string] $DefName)
    $def = Get-AzRoleDefinition -Name $DefName
    $ID = $Def.ID
    Write-Host "Found ID: '$ID' for name: '$DefName'"
    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs["GUID"] = $ID
    ```

    Note there are some specifics to how you return values from the PowerShell
    script to the template deployment. See [Use deployment scripts in ARM templates](https://learn.microsoft.com/azure/azure-resource-manager/templates/deployment-script-template#use-inline-scripts) for details.

## Template: main.bicep

This template wraps the UAI and RoleDefGUID modules.

Note that this deploys at at the

## Deployment process

You can use either

``` PowerShell
New-AzDeployment -Name TestDeploy -Location eastus -TemplateFile .\main.bicep -TemplateParameterFile '.\main.parameters.json'
```

``` sh
az deployment sub create --name 'TestDeploy' --location eastus --template-file .\main.bicep --parameters '.\main.parameters.json'

# Get all output objects
az deployment sub show --name 'TestDeploy' --query properties.outputs

# Specific value
az deployment sub show --name 'TestDeploy' --query properties.outputs.guid.value
```
