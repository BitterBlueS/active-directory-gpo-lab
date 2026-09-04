# Runbook: Access Change


## Purpose
Add, remove, or modify a user's group membership to grant or revoke access in response to a role change, project assignment, or offboarding

## When to Use
Triggered by a manager/HR request for a role change, a promotion or transfer, a temporary access need, or a user leaving a team/role

## Prerequisites
- Delegated rights to modify group membership in Active Directory Users and Computers (or Active DIrectory Administrative Center)
- Confirmation of the request (approval from the user's manager or a ticket referencing the change) do not modify access based on a verbal request alone
- Awareness of what each group actually controls (see notes below) before making the change

## Steps

## Adding a user to the group
1. Open 'Active Directory Users and Computers'
2. Locate the group (e.g., IT-Staff, Restricted-Members)
3. Right-click the group > Properties > Members tab > Add
4. Enter the user's logon name, click 'check names' to confirm the correct account, then 'ok'

## Removing a user from a group
1. Same path - group 'properties' > 'members' tab
2. Select the user, click 'remove', confirm

## Alternative: from the user's own object
Both actions can also be done from the user's account:
'Properties > Member Of' tab > 'Add/Remove.' Use whichever view is more convenient for the specific change

## Verification
- Confirm the current membership: 'Get-ADGroupMember -Identity "<GroupName>" | Select-Object Name, SamAccountName'
- Have the affected user log out and back in (or run 'gpupdate /force' on their workstation) group-based policy changes (password policy, application restrictions) do not apply retroactively to an active session
- Confirm the expected behavior change directly rather than assuming e.g., if removing a user from 'Restricted-Members', confirm they can now run previously blocked applications; if adding them, confirm the restriction now applies

## Common Issues / Troubleshooting
- Change does not seem to take effect: Group Policy does not apply to an already-active login session. Have the user log off/on, or run 'gpupdate /force' on their machine, before assuming the access change failed
- Unsure what a group actually controls: Before removing a user from a group (especially during an access reduction or the offboarding process), confirm what policies are tied to it. A single group can be the target of multipe GPOs/PSOs simultaneously (e.g., a group used for both password policy scoping and application restrictions). Removing someone from the wrong group, or failing to remove them from the right one, can have broader effects than the specific access change requested

## Escalation
If a requested access change is ambiguous, unusually broad, or not clearly approved, confirm with the requester's manager before making the change rather than proceeding on an assumption. Access changes should be traceable to a clear and approved request

