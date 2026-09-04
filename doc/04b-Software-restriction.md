# Group Policy: Software Restriction (Applocker)

## Approach
- Used AppLocker given the client is Windows 11 Enterprise, which fully supports AppLocker and is more current/relevant than other legacy software restriction policies

## Prerequisite
- Applicaiton Identity service must be running on the client system for AppLocker rules to be enforced, I did a quick double check of the client system services.msc startup configuations

## Group Scoping: Restricted-Members
- Applocker rules target either a single user or a group and don't support 'Everyone except X' natively. Deny rules also override allow rules regardles of specificity, so a broad 'Deny Everyone' + 'Allowed IT-Staff' combination would still effectively block IT-Staff members from accessing the blocked application that should be allowed for them.
- To scope the restriction to only general staff outside of the IT department, I created a Restricted-Members security group, assigning the Sales and HR users to this group while they also remain in their appropriate OU structure. Sales and HR users remain in their original OUs and were simply added to the new group.

## Rule Configuration
- GPO: Workstation-Applocker-Policy, linked to Workstations OU
- Default Executable Rules created first (baseline allow for Program Files/Windows) before adding any deny rules
- Deny rule: cmd.exe (%SYSTEM32%\cmd.exe), scoped to [Restricted-members], reducing shell access for standard users after creating that security group and adding the HR and Sales users as members

## Testing
- Ran the 'Gpupdate /force' command on the DC to update group policy settings
- Attempted to open Command Prompt on a restricted user in restricted-members and was blocked, with a system adminisitrator block message
- Verified block event in Event Viewer with event ID 8004 and that 'cmd.exe was prevented from running' for ARivera
- IT-Staff/Administrator: cmd.exe opened normally, confirming the deny rule correctly excluded IT given it's limited scope to users in the security group 'Restricted-members'

## Additional Notes
- Issue: After scoping the deny rule to Restricted-members, testing as CORP\Administrator showed cmd.exe/Windows Terminal blocked as well. Administrator is not a member of Restricted-members
- Diagnosis: Checked Event Viewer logs under AppLockers, specifically the EXE and DLL logs and found numerous 8002 (allow) and 8030 (informational) events but not 8004 (block) events. Indicating that AppLocker was not actually the source of the blockage. Reviewing the path condition of the deny rules on the DC I found a typo with the condition, missing the trailing % in '%System32\cmd.exe' which is required for AppLocker's path variable syntax to function properly
- Fix: Corrected the path condition, ran 'gpupdate /force' command on the DC and confirmed cmd.exe opened nromally for the administrator on the client system afterward via running a new task through task manager. Some virtualbox issues with the start windows menu working

## Key Takeaways
- Make sure to create the default rules in AppLocker before adding any specific deny rules, the default rules establish a baseline for allowed trusted system paths, it helps prevent an overly broad deny policy from blocking critical sytem functionalities
- AppLocker does not have 'everyone except group x' targeting, deny always overrides allow. Exclusions must be handled by scoping the deny rule to a group that doesn't include the excluded users, not by layerign competing Allow rules or some strange configuration
- OUs and groups serve different purposes: OU membership determiens directory location and GPO linkage, while group membership determiens policy/permission targeting. A user can belong to one OU but many different groups simultaneously
- Checking event logs for unexpected policy behavior is a huge time saver. Malformed conditions can result in misleading symptoms reflective of a scoping problem when the issue is something else.

