#OBS! DP02 Should be created and joined to the domain before running this script!

# IP addresses of the primary and secondary DHCP servers
$primaryDhcpServer = "172.30.9.17"
$secondaryDhcpServer = "172.30.9.18"

# Define the scopes to be created
$scopes = @("172.30.13.0")

# Prompt the user to enter the shared secret
$SecureSharedSecret = Read-Host -Prompt "Enter the shared secret" -AsSecureString

# Convert the SecureString to an encrypted standard string
$EncryptedSharedSecret = ConvertFrom-SecureString -SecureString $SecureSharedSecret

# Convert the encrypted string back to a SecureString
$SecureSharedSecret = ConvertTo-SecureString -String $EncryptedSharedSecret

# Convert the SecureString to a standard string for use in the script
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureSharedSecret)
$SharedSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Create the scopes
foreach ($scope in $scopes) {
    # Extract the base IP address
    $baseIp = $scope.Substring(0,$scope.LastIndexOf('.'))
    
    # Create the DHCP scope
    Add-DhcpServerv4Scope -ComputerName $primaryDhcpServer -Name $scope -StartRange "$baseIp.1" -EndRange "$baseIp.254" -SubnetMask 255.255.252.0 -State Active

    # Configure DHCP scope options
    Set-DhcpServerv4OptionValue -ComputerName $primaryDhcpServer -ScopeId $scope -Router "172.30.12.10" -DnsServer "172.30.9.11", "172.30.9.12" -DnsDomain "PING-IT.local"


    # Set NTP Server option (042)
    Set-DhcpServerv4OptionValue -ComputerName $primaryDhcpServer -ScopeId $scope -OptionId 42 -Value "172.30.9.11", "172.30.9.12"
}

# Create a DHCP failover relationship for all scopes
$failoverName = "DHCP01_FAILOVER_DHCP02"
$failoverExists = Get-DhcpServerv4Failover -ComputerName $primaryDhcpServer -Name $failoverName -ErrorAction SilentlyContinue

if ($null -eq $failoverExists) {
    Add-DhcpServerv4Failover -ComputerName $primaryDhcpServer -Name $failoverName -PartnerServer $secondaryDhcpServer -ScopeId $scopes -LoadBalancePercent 50 -SharedSecret $SharedSecret
}

# Allow for some delay for the failover relationship to establish
Start-Sleep -Seconds 30

# Check if failover exists for each scope
foreach ($scope in $scopes) {
    $failoverExists = Get-DhcpServerv4Failover -ComputerName $primaryDhcpServer -ScopeId $scope -ErrorAction SilentlyContinue

    # If the failover relationship doesn't exist, create one
    if ($null -eq $failoverExists) {
        Write-Output "Failover relationship for scope $scope does not exist. Creating now..."
        Add-DhcpServerv4Failover -ComputerName $primaryDhcpServer -Name $failoverName -PartnerServer $secondaryDhcpServer -ScopeId $scope -LoadBalancePercent 50
    }
}

# Replicate scopes
Invoke-DhcpServerv4FailoverReplication -ComputerName $primaryDhcpServer -Name "DHCP01_FAILOVER_DHCP02"

