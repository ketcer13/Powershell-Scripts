# Import the required module
Import-Module GroupPolicy

###__CREATING AFDELING GPOer__###
function New-DepartmentGPO ($GPOName, $OUPath, $wallpaperPath, $intranetSite, $AllowCMD, $AllowRun, $AllowPowershell) {
    # Create a new GPO
    New-GPO -Name $GPOName -Comment "Setting background and intranet site for department users"

    # Set the necessary registry keys to set the wallpaper and make it mandatory
    Set-GPRegistryValue -Name $GPOName -Key "HKCU\Control Panel\Desktop" -ValueName Wallpaper -Type String -Value $wallpaperPath
    Set-GPRegistryValue -Name $GPOName -Key "HKCU\Control Panel\Desktop" -ValueName WallpaperStyle -Type String -Value 2 # 2 = stretched to fit
    Set-GPRegistryValue -Name $GPOName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName Wallpaper -Type String -Value $wallpaperPath
    
    if (!$AllowCMD) {
        # Disable command prompt but still allow script processing
        Set-GPRegistryValue -Name $GPOName -Key "HKCU\Software\Policies\Microsoft\Windows\System" -ValueName DisableCMD -Type DWORD -Value 1
    }

    if (!$AllowRun) {
        # Disable "Run" command from Start Menu
        Set-GPRegistryValue -Name $GPOName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName NoRun -Type DWORD -Value 1
    }

    if (!$AllowPowershell) {
        # Enable "Don't run specified Windows applications" policy
        Set-GPRegistryValue -Name $GPOName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName DisallowRun -Type DWORD -Value 1

        # Disallow powershell.exe, powershell_ise.exe, pwsh.exe
        $disallowedApps = "powershell.exe", "powershell_ise.exe", "pwsh.exe"
        foreach ($app in $disallowedApps) {
            Set-GPRegistryValue -Name $GPOName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" -ValueName $app -Type String -Value $app
        }
    }

    # Link the GPO to the OU
    New-GPLink -Name $GPOName -Target $OUPath
}


# Define the array of GPO configurations
$GPOConfigurations = @(
    @{
        GPOName = "IT_Afdeling_GPO"
        OUPath = "OU=IT,OU=Afdelinger,DC=PING-IT,DC=local"
        wallpaperPath = "\\PING-FI01.PING-IT.local\AfdelingerBaggrunde\IT_Afdelinger_Baggrund.jpg"
        AllowCMD = $true
        AllowRun = $true
        AllowPowershell = $true
    },
    @{
        GPOName = "Administration_Afdeling_GPO"
        OUPath = "OU=Administration,OU=Afdelinger,DC=PING-IT,DC=local"
        wallpaperPath = "\\PING-FI01.PING-IT.local\AfdelingerBaggrunde\Administrations_Afdeling_Baggrund.jpg"
        AllowCMD = $false
        AllowRun = $false
        AllowPowershell = $false
    },
    @{
        GPOName = "Indkoeb_Afdeling_GPO"
        OUPath = "OU=Indkoeb,OU=Afdelinger,DC=PING-IT,DC=local"
        wallpaperPath = "\\PING-FI01.PING-IT.local\AfdelingerBaggrunde\Indkoeb_Afdeling_Baggrund.jpg"
        AllowCMD = $false
        AllowRun = $false
        AllowPowershell = $false
    },
    @{
        GPOName = "Ledelse_Afdeling_GPO"
        OUPath = "OU=Ledelse,OU=Afdelinger,DC=PING-IT,DC=local"
        wallpaperPath = "\\PING-FI01.PING-IT.local\AfdelingerBaggrunde\Ledelse_Afdeling_Baggrund.jpg"
        AllowCMD = $false
        AllowRun = $false
        AllowPowershell = $false
    },
    @{
        GPOName = "Oekonomi_Afdeling_GPO"
        OUPath = "OU=Oekonomi,OU=Afdelinger,DC=PING-IT,DC=local"
        wallpaperPath = "\\PING-FI01.PING-IT.local\AfdelingerBaggrunde\Oekonomi_Afdeling_Baggrund.jpg"
        AllowCMD = $false
        AllowRun = $false
        AllowPowershell = $false
    },
    @{
        GPOName = "Personale_Afdeling_GPO"
        OUPath = "OU=Personale,OU=Afdelinger,DC=PING-IT,DC=local"
        wallpaperPath = "\\PING-FI01.PING-IT.local\AfdelingerBaggrunde\Personale_Afdeling_Baggrund.jpg"
        AllowCMD = $false
        AllowRun = $false
        AllowPowershell = $false
    },
    @{
        GPOName = "Salg_Afdeling_GPO"
        OUPath = "OU=Salg,OU=Afdelinger,DC=PING-IT,DC=local"
        wallpaperPath = "\\PING-FI01.PING-IT.local\AfdelingerBaggrunde\Salg_Afdeling_Baggrund.jpg"
        AllowCMD = $false
        AllowRun = $false
        AllowPowershell = $false
    } 

)

# Use the function to create new GPOs based on the configurations
# Use the function to create new GPOs based on the configurations
foreach ($configuration in $GPOConfigurations) {
 New-DepartmentGPO -GPOName $configuration.GPOName -OUPath $configuration.OUPath -wallpaperPath $configuration.wallpaperPath -intranetSite $configuration.intranetSite -AllowCMD $configuration.AllowCMD -AllowRun $configuration.AllowRun -AllowPowershell $configuration.AllowPowershell

 }

