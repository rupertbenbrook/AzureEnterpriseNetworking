$timestamp = [int]((Get-Date).Subtract([datetime]"2016-08-08 00:00:00").TotalMinutes / 2)
$rgPrefix = "rb" + $timestamp   
$coreRg = $rgPrefix + "Core"
Select-AzureRmSubscription -SubscriptionName "Microsoft"
New-AzureRmResourceGroup -Name $coreRg -Location northeurope
New-AzureRmResourceGroupDeployment -DeploymentName $coreRg -ResourceGroupName $coreRg -TemplateFile ".\CoreNetwork.json" -TemplateParameterObject @{
    "namePrefix" = $rgPrefix;
    "locations" = @("northeurope", "westeurope");
    "locationVnetPrefixes" = @("10.0.", "10.1.");
    "adminUsername" = "Rupert";
    "adminPassword" = "P@55W0rd123!"
}
