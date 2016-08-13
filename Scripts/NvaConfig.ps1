# Install routing role on Windows
Install-WindowsFeature -Name Routing -IncludeManagementTools

# Enable forwarding on all adapters
Get-NetAdapter | Set-NetIPInterface -Forwarding Enabled

# Download and install Microsoft Message Analyzer
# TODO: Detect install and skip
#$mmaInstall = "$env:TEMP\MessageAnalyzer.msi"
#Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/8/3/283DE38A-5164-49DB-9883-9D1CC432174D/MessageAnalyzer64.msi" -OutFile $mmaInstall
#Start-Process -FilePath $mmaInstall -ArgumentList "/qn","/l*","$mmaInstall.log" -Wait
#Remove-Item -Path $mmaInstall -Force

# Run the VM config script
& .\VmConfig.ps1
