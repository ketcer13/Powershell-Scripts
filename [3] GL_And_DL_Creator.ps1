#Array of GL and DL Groups that will be tied together.
$groupStructure = @(
    @{
        GL = 'GL_Ledelse'; # Change 'YourNewGLGroup' to the name of your new Global group
        DL = @('DL_Ledelse_RE', 'DL_Ledelse_RW','DL_Ledelse_MO','DL_Bestyrelsesmoede_RW') # Add the names of the associated Domain Local groups here
    },
    @{
        GL = 'GL_Salg'; # Change 'YourNewGLGroup' to the name of your new Global group
        DL = @('DL_Salg_RE','DL_Salg_RW', 'DL_Salg_MO','DL_Salgindkoeb_MO') # Add the names of the associated Domain Local groups here
    },
     @{
        GL = 'GL_Indkoeb'; # Change 'YourNewGLGroup' to the name of your new Global group
        DL = @('DL_Indkoeb_RE','DL_Indkoeb_RW', 'DL_Indkoeb_MO','DL_Salgindkoeb_MO') # Add the names of the associated Domain Local groups here
    },
    
     @{
        GL = 'GL_Administration'; # Change 'YourNewGLGroup' to the name of your new Global group
        DL = @('DL_Administration_RE', 'DL_Administration_RW','DL_Administration_MO', 'DL_AdminOpgaver_RW') # Add the names of the associated Domain Local groups here
    },

     @{
        GL = 'GL_Personale'; # Change 'YourNewGLGroup' to the name of your new Global group
        DL = @('DL_Personale_RE','DL_Personale_RW', 'DL_Personale_MO') # Add the names of the associated Domain Local groups here
    },

    @{
        GL = 'GL_Oekonomi'; # Change 'YourNewGLGroup' to the name of your new Global group
        DL = @('DL_Oekonomi_RE','DL_Oekonomi_RW', 'DL_Oekonomi_MO') # Add the names of the associated Domain Local groups here
    },

     @{
        GL = 'GL_IT'; # Change 'YourNewGLGroup' to the name of your new Global group
        DL = @('DL_IT_RW', 'DL_IT_MO', 'DL_Manualer_MO') # Add the names of the associated Domain Local groups here
    },
    @{
        GL = 'GL_Programmer'; # Change 'YourNewGLGroup' to the name of your new Global group
        DL = @('DL_Programmer_MO', 'DL_Programmer_RE') # Add the names of the associated Domain Local groups here
    },

    @{
        GL = 'GL_Studerende'; #name of your new Global group
        DL = @('DL_Studerende_RE', 'DL_Studerende_RW','DL_Studerende_MO') # Add the names of the associated Domain Local groups here
    }

    @{
        GL = 'GL_Direktoer'; #name of your new Global group
        DL = @('DL_Bestyrelsesmoede_RE') # Add the names of the associated Domain Local groups here
    }

    @{
        GL = 'GL_SalgsChef'; #name of your new Global group
        DL = @('DL_Bestyrelsesmoede_RE') # Add the names of the associated Domain Local groups here
    }

    @{
        GL = 'GL_IndkoebsChef'; #name of your new Global group
        DL = @('DL_Bestyrelsesmoede_RE') # Add the names of the associated Domain Local groups here
    }

     @{
        GL = 'GL_PersonaleChef'; #name of your new Global group
        DL = @('DL_Bestyrelsesmoede_RE') # Add the names of the associated Domain Local groups here
    }

    @{
        GL = 'GL_KontorChef'; #name of your new Global group
        DL = @('DL_Bestyrelsesmoede_RE') # Add the names of the associated Domain Local groups here
    }

    @{
        GL = 'GL_OekonomiChef'; #name of your new Global group
        DL = @('DL_Bestyrelsesmoede_RE') # Add the names of the associated Domain Local groups here
    }

    @{
        GL = 'GL_ITChef'; #name of your new Global group
        DL = @('DL_Bestyrelsesmoede_RE') # Add the names of the associated Domain Local groups here
    }
     @{
        GL = 'GL_OpenVPN'; #name of your new Global group
        DL = @('DL_OpenVPN') # Add the names of the associated Domain Local groups here
    }
     @{
        GL = 'GL_RADIUS'; #name of your new Global group
        DL = @('DL_RADIUS_FW', 'DL_RADIUS_SSH') # Add the names of the associated Domain Local groups here
    }
     @{
        GL = 'GL_SNMPT'; #name of your new Global group
        DL = @('DL_SNMPT') # Add the names of the associated Domain Local groups here
    }
     @{
        GL = 'GL_LedelseShare'; #name of your new Global group
        DL = @('DL_LedelseShare_RW') # Add the names of the associated Domain Local groups here
    }
     @{
        GL = 'GL_ITElever'; #name of your new Global group
        DL = @('DL_ITElever') # Add the names of the associated Domain Local groups here
    }

    # ... Continue adding new hash tables for each Global group ...
    @{
        GL = 'GL_Baggrunde';
        DL = @('DL_Baggrunde_RE')
    }
      @{
        GL = 'GL_BackupAccess'; #name of your new Global group
        DL = @('DL_BackupAccess') # Add the names of the associated Domain Local groups here
    }
)

#Defines names to function
$gruppeOUName = "Gruppe_OU"
$glOUName = "GL"
$dlOUName = "DL"

# Create the OUs if they do not exist
if (!(Get-ADOrganizationalUnit -Filter {Name -eq $gruppeOUName} -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name $gruppeOUName -PassThru
}

# Check if the GL OU ($glOUName) exists under the group OU. If not, create it.
if (!(Get-ADOrganizationalUnit -Filter {Name -eq $glOUName} -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name $glOUName -Path "OU=$gruppeOUName,DC=Ping-IT,DC=local" -PassThru
}

# Check if the DL OU ($dlOUName) exists under the group OU. If not, create it.
if (!(Get-ADOrganizationalUnit -Filter {Name -eq $dlOUName} -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name $dlOUName -Path "OU=$gruppeOUName,DC=Ping-IT,DC=local" -PassThru
}

# Iterate through each item in the group structure
foreach ($item in $groupStructure) {
    $glGroupName = $item.GL
    $dlGroupNames = $item.DL

    # Get the GL groups under the GL OU
    $glGroups = Get-ADGroup -Filter * -SearchBase "OU=$glOUName,OU=$gruppeOUName,DC=Ping-IT,DC=local"
    if ($glGroups.Name -notcontains $glGroupName) {
        New-ADGroup -Name $glGroupName -GroupScope Global -Path "OU=$glOUName,OU=$gruppeOUName,DC=Ping-IT,DC=local" -PassThru
    }

    # Get the DL groups under the DL OU
    $dlGroups = Get-ADGroup -Filter * -SearchBase "OU=$dlOUName,OU=$gruppeOUName,DC=PSF,DC=com"

    # Iterate through each DL group name
    foreach ($dlGroupName in $dlGroupNames) {
        if ($dlGroups.Name -notcontains $dlGroupName) {
            New-ADGroup -Name $dlGroupName -GroupScope DomainLocal -Path "OU=$dlOUName,OU=$gruppeOUName,DC=Ping-IT,DC=local" -PassThru
        }

        # Add the GL group to the DL group
        try {
            Add-ADGroupMember -Identity $dlGroupName -Members $glGroupName
        }
        catch {
            Write-Host "Could not add $glGroupName to $dlGroupName"
        }
    }
}