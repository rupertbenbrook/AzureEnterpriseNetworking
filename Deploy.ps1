$scriptsStorageRg = "rbcommon"
$scriptsStorageAccount = "rbcommon"
$scriptsStorageContainer = "scripts"
$rgPrefix = "rbpeer"
$deployName = $rgPrefix + "-" + (Get-Date -Format "yyyyMMddHHmmss")
$rgLocation = "northeurope"
$templateParameters = @{
    "namePrefix" = $rgPrefix;
    "locations" = @("northeurope", "westeurope");
    "coreLocationVnetPrefixes" = @("10.0.", "10.1.");
    "liveLocationVnetPrefixes" = @("10.2.", "10.3.");
    "nonLiveLocationVnetPrefixes" = @("10.4.", "10.5.");
    "adminUsername" = "Rupert";
    "adminPassword" = "P@55W0rd123!"
}

# Upload scripts to storage
$context = New-AzureStorageContext -StorageAccountName $scriptsStorageAccount -StorageAccountKey (Get-AzureRmStorageAccountKey -ResourceGroupName $scriptsStorageRg -StorageAccountName $scriptsStorageAccount)[0].Value -ErrorAction Stop
New-AzureStorageContainer -Context $context -Name $scriptsStorageContainer -ErrorAction SilentlyContinue
Get-ChildItem -Path ".\Scripts" | %{
    Set-AzureStorageBlobContent -Context $context -Container $scriptsStorageContainer -Force -Blob $_.Name -File $_.FullName -ErrorAction Stop
}

# Get a SAS token for storage access
$token = New-AzureStorageContainerSASToken -Context $context -Container $scriptsStorageContainer -Permission r -Protocol HttpsOnly -ExpiryTime (Get-Date).AddHours(1) -ErrorAction Stop

# Add storage location and SAS token to template parameters
$templateParameters.Add("scriptsStorage", "https://$scriptsStorageAccount.blob.core.windows.net/$scriptsStorageContainer")
$templateParameters.Add("scriptsSasToken", $token)

# Create resource group and deploy template
New-AzureRmResourceGroup -Name $rgPrefix -Location $rgLocation -ErrorAction SilentlyContinue
New-AzureRmResourceGroupDeployment -DeploymentName $deployName -ResourceGroupName $rgPrefix -TemplateFile ".\EnterpriseNetwork.json" -TemplateParameterObject $templateParameters
