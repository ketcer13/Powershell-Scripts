# Set the new computer name and static IP details
$newComputerName = "PING-DC01"  # replace with your desired computer name
$ipAddress = "172.30.9.11"  # replace with your static IP address
$subnetMask = "24"  # replace with your subnet mask
$gateway = "172.30.9.1"  # replace with your gateway
$dns = "172.30.9.11"  # replace with your DNS

# Renames the computer
Rename-Computer -NewName $newComputerName -Force

# Enables Remote Desktop
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Changes the IP address
New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress $ipAddress -PrefixLength $subnetMask -DefaultGateway $gateway

# Sets the DNS
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses $dns

# Restarts the computer
Restart-Computer -Force