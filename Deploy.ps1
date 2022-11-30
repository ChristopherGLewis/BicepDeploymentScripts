New-AzDeployment -Name TestDeploy -Location eastus -TemplateFile .\main.bicep -TemplateParameterFile '.\main.parameters.json'
