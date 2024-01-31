

# Set NTP server to time.google.com
w32tm /config /manualpeerlist:"time.google.com" /syncfromflags:manual /reliable:yes /update

#Allows thru firewall 
netsh advfirewall firewall add rule name="NTP Server" dir=out protocol=udp localport=123 profile=any enable=yes action=allow
netsh advfirewall firewall add rule name="NTP Server" dir=in  protocol=udp localport=123 profile=any enable=yes action=allow

# Restart Windows Time service
Restart-Service w32time

# Verify configuration
$ntpServer = w32tm /query /configuration | Select-String -Pattern "NtpServer"
Write-Output ("NTP Server: {0}" -f $ntpServer)
