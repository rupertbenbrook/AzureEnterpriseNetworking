# Install routing role on Windows
Install-WindowsFeature -Name Routing -IncludeManagementTools

# Run the VM config script
& .\VmConfig.ps1
