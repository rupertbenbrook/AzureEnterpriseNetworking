param (
    [string] $ScriptsStorageRg = "rbcommon",
    [string] $ScriptsStorageAccount = "rbcommon",
    [string] $ScriptsStorageContainer = "scripts",
    [string] $RgPrefix = "rbpeer",
    [string] $RgLocation = "northeurope",
    $TemplateParameters = @{
        "namePrefix" = $RgPrefix;
        "locations" = @("northeurope", "westeurope");
        "coreLocationVnetPrefixes" = @("10.0.", "10.1.");
        "liveLocationVnetPrefixes" = @("10.2.", "10.3.");
        "nonLiveLocationVnetPrefixes" = @("10.4.", "10.5.");
        "adminUsername" = "Rupert";
        "adminPassword" = "P@55W0rd123!"
    }
)

# Create scripts storage if it doesn't exist
New-AzureRmStorageAccount -ResourceGroupName $ScriptsStorageRg -Name $ScriptsStorageAccount -Location $RgLocation -SkuName Standard_LRS -Kind Storage -ErrorAction SilentlyContinue

# Upload scripts to storage
$key = (Get-AzureRmStorageAccountKey -ResourceGroupName $ScriptsStorageRg -StorageAccountName $ScriptsStorageAccount)[0].Value
$context = New-AzureStorageContext -StorageAccountName $ScriptsStorageAccount -StorageAccountKey $key -ErrorAction Stop
New-AzureStorageContainer -Context $context -Name $ScriptsStorageContainer -ErrorAction SilentlyContinue
Get-ChildItem -Path ".\Scripts" | %{
    Set-AzureStorageBlobContent -Context $context -Container $ScriptsStorageContainer -Force -Blob $_.Name -File $_.FullName -ErrorAction Stop
}

# Get a SAS token for storage access
$expiry = (Get-Date).ToUniversalTime().AddDays(1)
$token = New-AzureStorageContainerSASToken -Context $context -Container $ScriptsStorageContainer -Permission r -Protocol HttpsOnly -ExpiryTime $expiry -ErrorAction Stop

# Add storage location and SAS token to template parameters
$TemplateParameters.Add("scriptsStorage", "https://$ScriptsStorageAccount.blob.core.windows.net/$ScriptsStorageContainer")
$TemplateParameters.Add("scriptsSasToken", $token)

# Create resource group and deploy template
$deployName = $RgPrefix + "-" + ((Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss"))
New-AzureRmResourceGroup -Name $RgPrefix -Location $RgLocation -ErrorAction SilentlyContinue
New-AzureRmResourceGroupDeployment -DeploymentName $deployName -ResourceGroupName $RgPrefix -TemplateFile ".\EnterpriseNetwork.json" -TemplateParameterObject $TemplateParameters
