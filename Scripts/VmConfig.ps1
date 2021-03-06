# Set network profile to private
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

# Allow file sharing (and ping)
Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True

# Turn off IE enhanced security for admins and users
$adminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$userKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $adminKey -Name "IsInstalled" -Value 0 -Force
Set-ItemProperty -Path $userKey -Name "IsInstalled" -Value 0 -Force
Stop-Process -Name Explorer

# Enable Windows SmartScreen
$smartScreenKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
Set-ItemProperty -Path $smartScreenKey -Name "SmartScreenEnabled" -Value "RequireAdmin" -Force             

# Enable Microsoft Update
$serviceManager = New-Object -ComObject "Microsoft.Update.ServiceManager"
$serviceManager.ClientApplicationID = "My App"
$serviceManager.AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")

# Download and extract iperf
if ((Test-Path -Path "C:\Tools\iperf-*") -eq $false) {
    $iperfZip = "$env:TEMP\iperf.zip"
    Invoke-WebRequest -Uri "https://iperf.fr/download/windows/iperf-3.1.3-win64.zip" -OutFile $iperfZip
    Add-Type -As System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($iperfZip, "C:\Tools")
    Remove-Item -Path $iperfZip -Force
}

# Download and extract SysInternals Tools
if ((Test-Path -Path "C:\Tools\SysInternals") -eq $false) {
    $sysInternalsZip = "$env:TEMP\SysInternals.zip"
    Invoke-WebRequest -Uri "https://download.sysinternals.com/files/SysinternalsSuite.zip" -OutFile $sysInternalsZip
    Add-Type -As System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($sysInternalsZip, "C:\Tools\SysInternals")
    Remove-Item -Path $sysInternalsZip -Force
}

# Allow iperf Server port
New-NetFirewallRule -DisplayName "iPerf Server TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5201
New-NetFirewallRule -DisplayName "iPerf Server UDP" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 5201

# Download and install any updates, rebooting if needed
Write-Host "Searching for updates..."
$update = New-Object -ComObject "Microsoft.Update.Session"
$updateSearch = $update.CreateUpdateSearcher()
$result = $updateSearch.Search("IsInstalled=0 and Type='Software'")
if ($result.Updates.Count -gt 0) {
    $result.Updates | Format-Table Title
    $downloads = New-Object -ComObject "Microsoft.Update.UpdateColl"
    $result.Updates | %{ $null = $downloads.Add($_) }
    $downloader = $update.CreateUpdateDownloader()
    $downloader.Updates = $downloads
    Write-Host "Downloading updates..."
    $null = $downloader.Download()
    $install = New-Object -ComObject "Microsoft.Update.UpdateColl"
    $result.Updates | ? IsDownloaded -eq $true | %{ $null = $install.Add($_) }
    $installer = $update.CreateUpdateInstaller()
    $installer.Updates = $install
    Write-Host "Installing updates..."
    $installResult = $installer.Install()
    if ($installResult.RebootRequired -eq $true) {
        Write-Host "Rebooting in 60 seconds"
        Start-Job -ScriptBlock { Start-Sleep -Seconds 60; Restart-Computer }
    }
}