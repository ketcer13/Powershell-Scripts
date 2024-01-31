# Set the domain, root OU, and group OU
$domain = "DC=PING-IT,DC=local"
$rootOU = "OU=Afdelinger"
$groupOU = "OU=GL,OU=Gruppe_OU,DC=PING-IT,DC=local"  # This is where your groups are

# Verify if the root OU exists
try {
    Get-ADOrganizationalUnit -Identity "$rootOU,$domain" -ErrorAction Stop
}
catch {
    # If the root OU does not exist, create it
    New-ADOrganizationalUnit -Name "Afdelinger" -Path $domain
}

# Employees to add
$csvPath = "C:\usersOU.csv"  # Replace with the actual path to your CSV file
$employees = Import-Csv -Path $csvPath

# Iterate over each employee
foreach ($employee in $employees){
    # Get the department
    $department = $employee.Department1
    }

    # Verify if the department OU exists, if not, create it
    try {
        Get-ADOrganizationalUnit -Identity "OU=$department,$rootOU,$domain" -ErrorAction Stop
    }
    catch {
        New-ADOrganizationalUnit -Name $department -Path "$rootOU,$domain"
    }

    # Define the username, profile path, and home directory
    $username = $employee.SamAccountName
    $profilePath = "\\PING-IT.local\PING-IT-FILSHARE\RoamingProfile\$username"
    $homeDirectory = "\\PING-IT.local\PING-IT-FILSHARE\Home\$username"

    # Define the user parameters
    $userParameters = @{
        GivenName             = $employee.GivenName
        Surname               = $employee.Surname
        Name                  = $employee.DisplayName
        UserPrincipalName     = $employee.UserPrincipalName
        SamAccountName        = $username
        Department            = $department
        Path                  = "OU=$department,$rootOU,$domain"
        AccountPassword       = ConvertTo-SecureString -AsPlainText $employee.Password -Force
        Enabled               = $true
        PasswordNeverExpires  = $true
        ProfilePath           = $profilePath
        HomeDirectory         = $homeDirectory
        HomeDrive             = 'H:'
    }

    # Create the new user
    $newUser = New-ADUser @userParameters -PassThru  # Use -PassThru to get the created user

    # Get the groups (these departments are also declared in the csv file)
    $groups = @($employee.Department1, $employee.Department2, $employee.Department3, $employee.Department4, $employee.Department5, $employee.Department6, $employee.Department7, $employee.Department8) | Where-Object { $_ } | ForEach-Object {
        if ($_ -eq 'Remote Desktop Users') {
            "CN=$_,CN=Builtin,$domain"
        } else {
            "CN=GL_$_,$groupOU"
        }
    }

    foreach ($groupName in $groups) {
        # Check if group exists
        if (!(Get-ADGroup -Identity $groupName -ErrorAction SilentlyContinue)) {
            Write-Error "Group ${groupName} does not exist. Skipping adding user $($newUser.SamAccountName) to group."
            continue
        }

        # Try to add the user to the group
        try {
                       Add-ADGroupMember -Identity $groupName -Members $newUser.SamAccountName
        }
        catch {
            Write-Error "Failed to add user $($newUser.SamAccountName) to group ${groupName}. Error: $_"
        }
    }

    # Add user to "Remote Desktop Users" group
    try {
        Add-ADGroupMember -Identity "CN=Remote Desktop Users,CN=Builtin,$domain" -Members $newUser.SamAccountName
    }
    catch {
        Write-Error "Failed to add user $($newUser.SamAccountName) to group 'Remote Desktop Users'. Error: $_"
    }

    # Add users in "IT" department to "GL_RADIUS" group
    if ($department -eq "IT") {
        # Add user to "GL_RADIUS" group
        try {
        Add-ADGroupMember -Identity "CN=GL_RADIUS,$groupOU" -Members $newUser.SamAccountName
        }
        catch {
            Write-Error "Failed to add user $($newUser.SamAccountName) to group 'GL_RADIUS'. Error: $_"
        }

    # Add users in "IT" department to "GL_SNMPT" group
    if ($department -eq "IT") {
        # Add user to "GL_SNMPT" group
        try {
        Add-ADGroupMember -Identity "CN=GL_SNMPT,$groupOU" -Members $newUser.SamAccountName
        }
        catch {
            Write-Error "Failed to add user $($newUser.SamAccountName) to group 'GL_SNMPT'. Error: $_"
        }
    }

      # Add every user to "GL_OpenVPN" group
    try {
        Add-ADGroupMember -Identity "CN=GL_OpenVPN,$groupOU" -Members $newUser.SamAccountName
    }
    catch {
        Write-Error "Failed to add user $($newUser.SamAccountName) to group 'GL_OpenVPN'. Error: $_"
    }

    # Add every user to "GL_Baggrunde" group
    try {
        Add-ADGroupMember -Identity "CN=GL_Baggrunde,$groupOU" -Members $newUser.SamAccountName
    }
    catch {
        Write-Error "Failed to add user $($newUser.SamAccountName) to group 'GL_Baggrunde'. Error: $_"
    }
}