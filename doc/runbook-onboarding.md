# Runbook: User Onboarding


## Purpose
Provision a new employee's Active Directory account with correct OU placement, group membership, and initial access

## When to use
Triggered by a new hire start date / HR onboarding request

## Prerequisites
-Domain Admin or delegated user-creation right in Active Directory Users and COmputers (or Active Directory Administrative Center)
-New Hire's: Full name, department (determines OU), and manager/role status (determines security group membership)
-Standard initial password per company password policy

## Steps

### Genearl Onboarding (multiple hires)
For onboarding one or more users at once (e.g., a new hire cohort, interns, or contractors) use the onboarding script instead of doing it manually:

1. Populate 'users.csv' with one row per new hire: 'FirstName, LastName, SamAccountName, OU, Password'
2. Confirm the file has a header row, import-csv treats the first line of the script as column names; a missing or modified header causes every field to bind incorrectly and the script will appear to run without creating real accounts.
3. Preview the parsed data before running the script, confirming accurate spelling and assignments: 'Import-Csv .\users.csv | Format-Table'
4. Run the script: '.\New-BulkADUsers.ps1'
5. This script is singularly responsible for creation and OU placement, group memberships will be handled by another script.

### Manual Single User Onboarding
In case of an issue arising with the general onboarding script, the manual process is listed below covering every step necessary. Familiarity with the manual process is a necessity:

1. Open 'Active DIrectory Users and Computers' on the domain controller.
2. Navigate to the OU matching the employee's department ('IT', 'Sales, or 'HR').
3. Right-click the OU > New > User
4. Enter first name, last name, and a logon name following the convention: first initial + lastname (e.g., 'JSmith')
5. Set an initial password. Leave 'User must change password at next logon' checked, so that the new hire sets their own password on first login. Except if the user is a remote user who for remote access purposes the option will cause login issues, so it should be unchecked.
6. Finish creating the account.
7. Add the user to the appropriate security group(s) based on role (e.g., 'IT-Staff' for IT department members) via the group's 'Members' tab, or the user's 'Members of' tab.

## Verification
-Confirm the account exists and is in the correct OU through powershell: 'Get-ADUser -Identity <SamAccountName> -Properties MemberOf | Select-Object Name, DistinguishedName, MemberOf'
-Have the new hire (or IT if a further password change is not necessary) login from a domain-joined workstation to confirm authentication suceeds and group-based policies (e.g., password policy, application restrictions) apply as expected of their role

## Common Issues / Troubleshooting
-'SamAccountName / UPN Collision': IF a new hire shares initials and a last name with an existing user (e.g., two John Smith's), account creation will fail with a 'not unique forest-wide' error. Resolve by adjusting the naming convention for the new account (e.g., append a number or use a middle initial). Confirm existing conventions, following what the current team does, do not guess or create these account names arbitrarily.
-General Script 'succeeds' but no account appears in AD: Check that 'users.csv' has a valid header row before assuming a deeper scripting issue. Console/echo output reporting success while generally accurate may include an error but still return as successful. Always verify with 'Get-ADUser' against the actual directory.

## Escalation




