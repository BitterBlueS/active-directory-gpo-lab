# Client Join

## Environment
- Windows 11 Enterprise (evaluation iso)
- Virtualbox: 8GB RAM, 3 cores, EFI + TPM 2.0 enabled, internal network (intnet)

## Static IP Configuration
- IP: 192.168.10.2 / 255.255.255. 0 (Similar private IP address in the class C range)
- DNS: 192.168.10.1 (Points to the DC - necessary for the client VM to locate the domain via the DNS server, unlike the DC which can point to itself)

## Steps
- Verified the connectivity/DNS resolution before joining the client vm to the domain via ping + nslookup commands
- Joined the corp.local domain via the System Properties tab changing the domain/workgroup of the client, entering the CORP\Administrator information
- Rebooted and confirmed the domain login, logged in with domain administrator accounter

## Verification
- Ran the 'whoami' command line interface command and the '$env:USERDNSDOMAIN' powershell command to confirm the new domain identity on the client
- Ran the 'Get-ADComputer -Filter *' command on the DC server to confirm the server has identified and registered the client's computer as an object

## Environment Decision: Domain Accounts Only
- After losing practical access to the client's original local account after joining/changing to the CORP domain, and not maintaining appropriate documentation of the local account, I've decided to standardize the usage of domain accounts for all client login/testing going forward rather than attempting to restore local account access. This is likewise more representative of a real domain environment, where day-to-day workstation logins are domain-based rather than local accounts that complicate management.

## Additional Notes
- Issue: Initially got an invalid username suggesstion when entering the CORP\Administrator information for the domain change
- Fix: I was using the wrong slash, I used the forward slash (/) and not the backward slash (\) that is used in the NetBIOS-formatting with credentials
- Takeaway: Double check for syntax and spelling errors that might result in unexpected or misleading error messages, verify the exact formatting required before considering a deeper connectivity or authentication issue

- Issue #2: After joining the client system to the domain I could no longer log into the original local account using just the username in addition to changes to the login screen
- Fix: THe local account still exists but it requires ecplicit local-account notation to login including '.\username' or the selection of 'Other User' given it now defaults to the domain login
- Takeaway: Domain join changes login defaults/expectations, it's critical to confirm the exact account information and formatting for local login in the future otherwise access to the local account might be lost. The issue is mute but worth keeping in mind considering I will create a new domain user back on the DC, confirming it's login capabilities and other functions through the client vm and system.

