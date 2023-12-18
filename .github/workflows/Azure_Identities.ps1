$azureContext = Get-AzContext

$githubOrganizationName = 'rozkurt'
$githubRepositoryName = 'toy-website-environments'

# Run the following code that creates a workload identity for the test environment and associates it with your GitHub repository:

$testApplicationRegistration = New-AzADApplication -DisplayName 'toy-website-environments-test'
New-AzADAppFederatedCredential `
   -Name 'toy-website-environments-test' `
   -ApplicationObjectId $testApplicationRegistration.Id `
   -Issuer 'https://token.actions.githubusercontent.com' `
   -Audience 'api://AzureADTokenExchange' `
   -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):environment:Test"
New-AzADAppFederatedCredential `
   -Name 'toy-website-environments-test-branch' `
   -ApplicationObjectId $testApplicationRegistration.Id `
   -Issuer 'https://token.actions.githubusercontent.com' `
   -Audience 'api://AzureADTokenExchange' `
   -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):ref:refs/heads/main"

   # Run the following code that creates a workload identity for the Production environment and associates it with your GitHub repository:

   $productionApplicationRegistration = New-AzADApplication -DisplayName 'toy-website-environments-production'
New-AzADAppFederatedCredential `
   -Name 'toy-website-environments-production' `
   -ApplicationObjectId $productionApplicationRegistration.Id `
   -Issuer 'https://token.actions.githubusercontent.com' `
   -Audience 'api://AzureADTokenExchange' `
   -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):environment:Production"
New-AzADAppFederatedCredential `
   -Name 'toy-website-environments-production-branch' `
   -ApplicationObjectId $productionApplicationRegistration.Id `
   -Issuer 'https://token.actions.githubusercontent.com' `
   -Audience 'api://AzureADTokenExchange' `
   -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):ref:refs/heads/main"

   # To create the test environment's resource group and grant the workload identity access to it, run the following Azure PowerShell commands in the Visual Studio Code terminal

   $testResourceGroup = New-AzResourceGroup -Name ToyWebsiteTest -Location westus3

New-AzADServicePrincipal -AppId $($testApplicationRegistration.AppId)
New-AzRoleAssignment `
   -ApplicationId $($testApplicationRegistration.AppId) `
   -RoleDefinitionName Contributor `
   -Scope $($testResourceGroup.ResourceId)

      # To create the Production environment's resource group and grant the workload identity access to it, run the following Azure PowerShell commands in the Visual Studio Code terminal

      $productionResourceGroup = New-AzResourceGroup -Name ToyWebsiteProduction -Location westus3

New-AzADServicePrincipal -AppId $($productionApplicationRegistration.AppId)
New-AzRoleAssignment `
   -ApplicationId $($productionApplicationRegistration.AppId) `
   -RoleDefinitionName Contributor `
   -Scope $($productionResourceGroup.ResourceId)

   # Run the following code to show you the values you need to create as GitHub secrets:

   $azureContext = Get-AzContext
Write-Host "AZURE_CLIENT_ID_TEST: $($testApplicationRegistration.AppId)"
Write-Host "AZURE_CLIENT_ID_PRODUCTION: $($productionApplicationRegistration.AppId)"
Write-Host "AZURE_TENANT_ID: $($azureContext.Tenant.Id)"
Write-Host "AZURE_SUBSCRIPTION_ID: $($azureContext.Subscription.Id)"
