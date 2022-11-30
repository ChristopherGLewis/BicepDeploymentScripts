az deployment sub create --name 'TestDeploy' --location eastus --template-file .\main.bicep --parameters '.\main.parameters.json'
az deployment sub show --name 'TestDeploy' --query properties.outputs
