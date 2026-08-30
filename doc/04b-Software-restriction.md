# Group Policy: Software Restriction (Applocker)

## Approach
Used AppLocker given the client is Windows 11 Enterprise, which fully supports AppLocker and is more current/relevant than other legacy software restriction policies

## Prerequisite
-Applicaiton Identity service must be running on the client system for AppLocker rules to be enforced, I did a quick double check of the client system services.msc startup configuations

## Rule Configuration
-GPO: Workstation-Applocker-Policy, linked to Workstations OU
-Default Executable Rules created first (baseline allow for Program Files/Windows) before adding any deny rules
-Deny rule: cmd.exe (%SYSTEM32%\cmd.exe), scoped to [Everyone / general users], to reduce shell access for standard accounts

## Testing
-Gpupdate /force on client system
-Attempted to open Command Prompt as a restricted user - blocked, with system adminisitrator block message
-Verified block event in Event Viewer








