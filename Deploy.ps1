$timestamp = [int]((Get-Date).Subtract([datetime]"2016-08-08 00:00:00").TotalMinutes / 2)
$rgPrefix = "rb" + $timestamp   
$coreRg = $rgPrefix + "core"
$liveRg = $rgPrefix + "live"
$nliveRg = $rgPrefix + "nlive"
$path = [string](Resolve-Path ".")
Save-AzureRmProfile -Path "$path\AzureProfile.json" -Force
$coreJob = Start-Job -Name "Core" -ArgumentList ($path, $coreRg) -ScriptBlock {
    param (
        $path,
        $rgPrefix
    )
    Select-AzureRmProfile -Path "$path\AzureProfile.json"
    Select-AzureRmSubscription -SubscriptionName "Microsoft"
    New-AzureRmResourceGroup -Name $rgPrefix -Location northeurope
    $parameters = @{
        "namePrefix" = $rgPrefix;
        "locations" = @("northeurope", "westeurope");
        "locationVnetPrefixes" = @("10.0.", "10.1.");
        "adminUsername" = "Rupert";
        "adminPassword" = "P@55W0rd123!"
    }
    $parameters
    New-AzureRmResourceGroupDeployment -DeploymentName $rgPrefix -ResourceGroupName $rgPrefix -TemplateFile "$path\CoreNetwork.json" -TemplateParameterObject $parameters
}
$liveJob = Start-Job -Name "Live" -ArgumentList ($path, $liveRg) -ScriptBlock {
    param (
        $path,
        $rgPrefix
    )
    Select-AzureRmProfile -Path "$path\AzureProfile.json"
    Select-AzureRmSubscription -SubscriptionName "Microsoft"
    New-AzureRmResourceGroup -Name $rgPrefix -Location northeurope
    $parameters = @{
        "namePrefix" = $rgPrefix;
        "locations" = @("northeurope", "westeurope");
        "locationVnetPrefixes" = @("10.2.", "10.3.");
        "adminUsername" = "Rupert";
        "adminPassword" = "P@55W0rd123!"
    }
    $parameters
    New-AzureRmResourceGroupDeployment -DeploymentName $rgPrefix -ResourceGroupName $rgPrefix -TemplateFile "$path\DeployNetwork.json" -TemplateParameterObject $parameters
}
$nliveJob = Start-Job -Name "Non-Live" -ArgumentList ($path, $nliveRg) -ScriptBlock {
    param (
        $path,
        $rgPrefix
    )
    Select-AzureRmProfile -Path "$path\AzureProfile.json"
    Select-AzureRmSubscription -SubscriptionName "Rupert Benbrook (MSDN)"
    New-AzureRmResourceGroup -Name $rgPrefix -Location northeurope
    $parameters = @{
        "namePrefix" = $rgPrefix;
        "locations" = @("northeurope", "westeurope");
        "locationVnetPrefixes" = @("10.4.", "10.5.");
        "adminUsername" = "Rupert";
        "adminPassword" = "P@55W0rd123!"
    }
    $parameters
    New-AzureRmResourceGroupDeployment -DeploymentName $rgPrefix -ResourceGroupName $rgPrefix -TemplateFile "$path\DeployNetwork.json" -TemplateParameterObject $parameters
}
Wait-Job -Job @($coreJob, $liveJob, $nliveJob)
#Add-AzureRmVirtualNetworkPeering -Name "$rgPrefix-" -VirtualNetwork xxx -RemoteVirtualNetworkId xxx