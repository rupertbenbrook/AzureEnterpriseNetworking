# Set network profile to private
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

# Allow file sharing (and ping)
Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True

# Turn off IE enhanced security for admins
$adminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $adminKey -Name "IsInstalled" -Value 0

# Download and extract iperf
$iperfZip = "$env:TEMP\iperf.zip"
Invoke-WebRequest -Uri "https://iperf.fr/download/windows/iperf-3.1.3-win64.zip" -OutFile $iperfZip
Add-Type -As System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($iperfZip, "Read" )
[System.IO.Compression.ZipFileExtensions]::ExtractToDirectory($zip, "C:\")
$zip.Dispose()
Remove-Item -Path $iperfZip -Force

# Allow iperf Server port
New-NetFirewallRule -DisplayName "iPerf Server TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5201
New-NetFirewallRule -DisplayName "iPerf Server UDP" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 5201
