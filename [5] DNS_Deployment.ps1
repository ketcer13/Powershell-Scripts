# Specify the domain controllers
$dc1 = "PING-DC01"
$dc1IP = "172.30.9.11" # replace 'dc1 IP Address' with the actual IP address of dc1
$dc2 = "PING-DC02"

# Define an array with your devices and their corresponding IP addresses
$devices = @(
# Server Devices.
    @{ Name = "PING-ESXI01"; IP = "172.30.9.31" },
    @{ Name = "PING-ESXI02"; IP = "172.30.9.32" },
    @{ Name = "PING-ESXI03"; IP = "172.30.9.33" },
    @{ Name = "PING-ESXI04"; IP = "172.30.9.34" },
    @{ Name = "PING-FI01"; IP = "172.30.9.15" },
    @{ Name = "PING-FI02"; IP = "172.30.9.16" },
    @{ Name = "PING-DHCP01"; IP = "172.30.9.17" },
    @{ Name = "PING-DHCP02"; IP = "172.30.9.18" },
    @{ Name = "PING-ILO01"; IP = "172.30.9.21" },
    @{ Name = "PING-ILO02"; IP = "172.30.9.22" },
    @{ Name = "PING-ILO03"; IP = "172.30.9.23" },
    @{ Name = "PING-ILO04"; IP = "172.30.9.24" },
    @{ Name = "PING-VSP01"; IP = "172.30.9.30" },
    @{ Name = "PING-SNMP01"; IP = "172.30.9.51" },
    @{ Name = "PING-SYS01"; IP = "172.30.9.52" },
    
    # Network Devices.
    @{ Name = "PING-FW01"; IP = "172.30.9.2" },
    @{ Name = "PING-FW02"; IP = "172.30.9.3" },
    @{ Name = "PING-SWL301"; IP = "172.30.9.254" },
    @{ Name = "PING-SWL201"; IP = "172.30.9.253" }
)

# Check if the zone already exists
$zoneExists = Get-DnsServerZone -ComputerName $dc1 -Name "PING-IT.local" -ErrorAction SilentlyContinue

# Only create the zone if it does not already exist
if ($null -eq $zoneExists) {
    Add-DnsServerPrimaryZone -ComputerName $dc1 -Name "PING-IT.local" -ReplicationScope "Domain" 
}

# Create reverse lookup zones on the primary DC for /24 subnets
$reverseZones24 = "9.30.172", "10.30.172", "12.30.172"
foreach ($reverseZone in $reverseZones24) {
    $networkId = "$reverseZone.in-addr.arpa" # Changes here: Removed ".0/24"

    # Check if the reverse DNS zone already exists
    $zoneExists = Get-DnsServerZone -ComputerName $dc1 -Name $networkId -ErrorAction SilentlyContinue

    # Only create the zone if it does not already exist
    if ($null -eq $zoneExists) {
        Add-DnsServerPrimaryZone -ComputerName $dc1 -Name $networkId -ReplicationScope "Forest"
    }
}

# Create DNS entries on the primary DC
foreach ($device in $devices) {
    try {
        # Add A record
        Add-DnsServerResourceRecordA -ComputerName $dc1 -ZoneName "PING-IT.local" -Name $device.Name -IPv4Address $device.IP -CreatePtr -ErrorAction Stop
        Write-Host "Successfully added A record for $($device.Name)"
    } catch {
        Write-Host "Failed to add A record for $($device.Name): $($_.Exception.Message)"
    }

    try {
        # Create PTR
        $reverseOctets = ($device.IP.Split(".")[0..2]) -join "."
        $lastPartOfIP = $device.IP.Split(".")[-1]
        Add-DnsServerResourceRecordPtr -ComputerName $dc1 -ZoneName "$reverseOctets.in-addr.arpa" -Name $lastPartOfIP -PtrDomainName "$device.Name.PING-IT.local" -ErrorAction Stop
        Write-Host "Successfully added PTR record for $($device.Name)"
    } catch {
        Write-Host "Failed to add PTR record for $($device.Name): $($_.Exception.Message)"
    }
    # Add CNAME record for each device
    $cname = $device.Name.Split("-")[-1]
    try {
    Add-DnsServerResourceRecordCName -ZoneName "PING-IT.local" -Name "$cname" -HostNameAlias "$($device.Name).PING-IT.local" -ComputerName $dc1 -ErrorAction Stop
    Write-Host "Successfully added CNAME record for $($device.Name)"
} catch {
    Write-Host "Failed to add CNAME record for $($device.Name): $($_.Exception.Message)"
}

}


#Now, setup secondary DNS server with zone transfer from the primary

# NOTE!!!!!!!!!!: Make sure to allow Zone Transfers on the primary DNS server

Add-DnsServerSecondaryZone -ComputerName $dc2 -Name "PING-IT.local" -ZoneFile "PING-IT.local.dns" -MasterServers $dc1IP


