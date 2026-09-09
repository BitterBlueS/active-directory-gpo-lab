<#
.SYNOPSIS
    Generally provisions AD user accounts, singular or in bulk from a CSV onboarding file
.DESCRIPTION
    The script validates CSV data (including fields, duplicate account names, and valid OU 
    entries) before creating any accounts. It generates a random temporary password per user 
    rather than reading one from the CSV file in an unecrypted format that is insecure. 
    Lastly, it logs results (including temp passwords) to a timestamped CSV for secure handoff.
.PARAMETER CsvPath
    Path to the CSV file containing user FirstName, LastName, SamAccountName, and OU Columns.
.PARAMETER LogPath
    Path to where the results log (including generated temp Passwords) will be written.
#>



param(
    [string]$CsvPath = ".\users.csv",
    [string]$LogPath = ".\onboarding-log-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
)

function New-RandomPassword {
    $length = 16
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#$%'
    -join (1..$length | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}


# Validation pass: catch problems before provisioning
$users = Import-Csv -Path $CsvPath
$validationErrors = @()

foreach ($user in $users) {
    if (-not $user.FirstName -or -not $user.LastName -or -not $user.SamAccountName -or -not $user.OU) {
        $validationErrors += "Row missing a required field: $($user | Out-String)"
        continue
    }
    if (Get-ADUser -Filter "SamAccountName -eq '$($user.SamAccountName)'" -ErrorAction SilentlyContinue) {
        $validationErrors += "SamAccountName already exists: $($user.SamAccountName)"
    }
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$($user.OU)'" -ErrorAction SilentlyContinue)) {
        $validationErrors += "OU not found: $($user.OU)"
    }
}

if ($validationErrors.Count -gt 0) {
    Write-Host "Validation failed - no accounts were created:" -ForegroundColor Red
    $validationErrors | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    return
}



# Creation pass: only runs if validation passed
$results = @()

foreach ($user in $users) {
    $tempPassword = New-RandomPassword
    $securePassword = ConvertTo-SecureString $tempPassword -AsPlainText -Force

    try {
        New-ADUser `
            -Name "$($user.FirstName) $($user.LastName)" `
            -GivenName $user.FirstName `
            -Surname $user.LastName `
            -SamAccountName $user.SamAccountName `
            -UserPrincipalName "$($user.SamAccountName)@corp.local" `
            -Path "OU=$($user.OU),DC=corp,DC=local" `
            -AccountPassword $securePassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -ErrorAction Stop

        Write-Host "Created: $($user.SamAccountName)" -ForegroundColor Green
        $results += [PSCustomObject]@{
            SamAccountName = $user.SamAccountName
            Status         = "Created"
            TempPassword   = $tempPassword
            Timestamp      = Get-Date
        }
    }
    catch {
        Write-Host "FAILED: $($user.SamAccountName) - $($_.Exception.Message)" -ForegroundColor Red
        $results += [PSCustomObject]@{
            SamAccountName = $user.SamAccountName
            Status         = "Failed: $($_.Exception.Message)"
            TempPassword   = ""
            Timestamp      = Get-Date
        }
    }
}



# Log results
$results | Export-Csv -Path $LogPath -NoTypeInformation
Write-Host ""
Write-Host "Log written to $LogPath"
Write-Host "Note: log contains temporary passwords. Handle/store securely, delete after distribution."

