#install the Remote Server Administration Tools
Install-WindowsFeature RSAT-ADDS

# Import the Server Manager module
Import-Module ServerManager

# Install the AD DS role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Import the AD DS deployment module
Import-Module ADDSDeployment

Start-Sleep -Seconds 15

# Defines domain and safe mode administrator password
$domainName = "Ping-IT.local"
$safeModeAdministratorPassword = ConvertTo-SecureString -String "Kodeord12345!" -AsPlainText -Force

# Install a new forest
Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName $domainName `
    -DomainNetbiosName ( $domainName.Split(".")[0] ) `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true `
    -SafeModeAdministratorPassword $safeModeAdministratorPassword