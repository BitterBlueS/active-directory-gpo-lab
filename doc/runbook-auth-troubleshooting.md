# Runbook: Authentication Troubleshooting

## Purpose
Triggered by a 'can't log in' or 'wrong password' report, or a report that a user has unexpectedly lost access to something after a domain change (join, group change, etc.)

## Prerequisites
- Access to the affected workstation (or ability to guide the user through steps remotely)
- Domain Admin or helpdesk-level access to Active Directory Users and COmputers, for checking account status
- User's exact logon name and which account type they're attempting (domain vs. local)

## Decision Tree

## 1. Confirm exactly what's being types
A large share of 'can't log in' reports are credential formatting issues, not real account/connectivity problems
-Domain Accounts requrie 'DOMAIN\username/ or 'username@domain.com' format. Confirm the backslash ('\'), no forward slash ('/'), is used in NetBIOS-format entries
-Confirm Caps Lock is off and the correct keyboard layout is active, especially in virtualized environments where layout mismatches can silently alter special characters in passwords

## 2. Determine domain vs. local account confusion
If a user reports their 'usual' login no longer works after a recent domain join or account change:
- Ask whether they're trying their 'local' account ot their 'domain' account. The two are not interchangeable, and a domain join changes the login screen's default target to the domain
- To explicitly log in to a 'local' account on a domain-joined machine: select 'Other User', and prefix the username with '.\' (e.g., '.\localadmin')

## 3. Check account status in Active Directory
'Get-ADUser -Identity <username> -Properties LockedOut, Enabled, PasswordExpired'
- 'LockedOut = True': account is locked, typically from repeated failed attempts. Unlock via Active Directory Users and COmputers > user Properties > 'Account' tab > 'Unlock Account'
- 'Enabled = False': account has been disabled. Confirm this is expected (e.g., offboarding) before re-enabling
- 'PasswordExpired = true': password has expired per policy; user needs to reset it, or an admin can force a reset

## 4. Check connectivity and DNS resolution (client-side)
Domain login requires the client to reach the domain controller. If the account status in AD looks normal, check the network path from the affected workstation:
'ping <DC IP address> nslookup <domain name>'

If either fails, the issue is network/DNS, not the account itself. Escalate to network/infrastructure rather than continuing to troubleshoot the account

## 5. Check for time skew
Kerberos authentication (used for domain login) is sensitive to clock drift between the client and domain controller. If login fails with a time-related error, or fails intermittently:
'w32tm /query /status'

Confirm the client's clock is within a few minutes of the domain controller's. In a domain environment, workstations should sync time from the DC automatically. A large drift suggests the time sync service itself needs attention, not just a one-time clock fix

## 6. If login succeeds but expected access is missing
THis is a different problem than login failure. THe account works, but behavior is wrong (e.g., an appis blocked that shouldn't be, or a policy isn't applying as expected)
- Confirm the user's current group memberships match what's expected. A recent access chagne may not have taken effect if the user hasn't logged off/on since (see 'runbook-access-change.md')
- Dont' assume a blocked action is an authentication problem. Application restriction policies (e.g., AppLocker) can produce a 'blocked by your system administrator' message that looks like an access/auth issue but is actually a separate policy layer. Check Event Viewer ('Applications and Service Logs > Microsoft > Windows > AppLocker > EXE and DLL') for a specific block event before assuming it's account-related

## Verification
- Confirm the user can log in successfully with the corrected credentials/account
- If the fix involved a policy or group change, confirm expected behavior directly (app runs/doesn't run, correct password policy applies) rather than assuming login success alone confirms the fix

## Escalation
If account status, connectivity, and time sync all check out normall and login still fails, escalate to a senior admin. This may indicate a deeper AD replication or Kerberos ticketing issue beyond standard helpdesk-level troubleshooting

