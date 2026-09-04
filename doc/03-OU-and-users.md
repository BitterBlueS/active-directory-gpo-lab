# OU Structure $ User Provisioning

## OU Structure
- IT
- Sales
- HR
- Workstations (for computer objects, required for proper GPO targeting)

## Users Created

## Manual Initial Testing
- Jenna Smith (JSmith) under the IT OU is the first test client login after the initial domain-join of the client system after the local account issue (See 02-Client-join.md for details)

## Bulk Users Provisioning via PowerShell (New-ADUser + CSV)
- 8 of 9 planned users were sucessfully created across the Sales, IT, and HR OU's via 'scripts/New-BulkADUsers.ps1' and 'users.csv'
- Chose CSV + Powershell over manual creation to simulate a more realistic bulk onboarding approach to new hires though in some cases it might still be done one by one. A script based-approach enabline some automation provides a consistent and established baseline for configuration and management
- 1 user ("John Smith") failed due to a naming collision with another user (see additional notes)

## Groups
- IT-Staff (Global, Security) - created under IT OU, members: jsmith, jblake

## Verification
- Ran the powershell command 'Import-Csv .\users.csv | Format-Table' to confirm the CSV was parsing correctly before running the bulk user creation script
- Ran the powershell command 'Get-ADUser -Filter * -SearchBase "DC=corp,DC=local" | Select-OBject Name, SamAccountName confirmed users were created in AD

## Additional Notes

- Issue: Could not reliably drag-and-drop or copy/paste the scripts between my host system and the DC VM, VirtualBox reported that Guest Additions were not installed
- Fix: INstalled VirtualBox Guest Additions on the DC via Devices>Insert Guest Additions CD image>ran installer>rebooted), which enabled clipboard functionality between the host and guest after switching the vm settings to function bidirectionally
- Takeaway: Guest Additions is more than a convenience and worth installing for copy/paste or drag-and-drop functionaility, especially in light of scripting errors that might be confused with environment or tooling issues. Worth installing or verifying earlier.

- Issue #2: Bulk user creation script failed with the error "cannot bind argument to parameter 'String' because it is null," despite Write-Host reporting each user as "Created."
- Cause: The users.csv file was initially missing the header row which I removed after writing, I initially considered it to be a placeholder rather than column headers, so every row of the script was referencing non-existent properties and each New-ADUser call was silently failing
- Fix: Added the correct header row in the first line of users.csv file
- Takeaway: Scripts reporting success in some metric but returning an error is not at all an indication of successful operations, it is always worth verifying against the actual system. I used the Get-ADUser against the AD in addition to directly checking through Users and Computers rather than trusting the output in the console. This further reinforced the need for previewing whether CSV data is correctly parsing before running a script reliant on the information, printing out a table with parse CSV data was especially helpful in verifying that the missing column headers were the cause.

- Issue #3: Bulk script failed to create one user ("John Smith") because the "UPN value provided for addition/modification is not unique forest-wide."
- Cause: The SamAccountName/UPN collision is a result of the existing testu user previously created, ie, Jenna Smith (JSmith) with the same account credentials
- Takeaway: Naming collissions are a real provisioning concern and a real-world onboarding process needs defined conventions for handling duplicated names (whether it be appending a number to it or utilizing a middle initial). The missing 9th user will be uncorrected intentionally, it's a realistic example of a provisioning edge case/issue that while simplistic in nature is likely to happen in larger organizations.

