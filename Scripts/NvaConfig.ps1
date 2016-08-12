# Run the VM config script
& .\VmConfig.ps1

# Install routing role on Windows
Install-WindowsFeature -Name Routing -IncludeManagementTools
