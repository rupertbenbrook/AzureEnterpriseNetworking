#$timestamp = [int]((Get-Date).Subtract([datetime]"2016-08-08 00:00:00").TotalMinutes / 2)
$rgPrefix = "rbpeer" # + $timestamp   
$rgPrefix
Select-AzureRmSubscription -SubscriptionName "Microsoft"
New-AzureRmResourceGroup -Name $rgPrefix -Location "northeurope"
New-AzureRmResourceGroupDeployment -DeploymentName $rgPrefix -ResourceGroupName $rgPrefix -TemplateFile ".\EnterpriseNetwork.json" -TemplateParameterObject @{
    "namePrefix" = $rgPrefix;
    "locations" = @("northeurope", "westeurope");
    "coreLocationVnetPrefixes" = @("10.0.", "10.1.");
    "liveLocationVnetPrefixes" = @("10.2.", "10.3.");
    "nonLiveLocationVnetPrefixes" = @("10.4.", "10.5.");
    "adminUsername" = "Rupert";
    "adminPassword" = "P@55W0rd123!"
}
