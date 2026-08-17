# Domain Controller Setup

##Environment
- Windows Server 2022 Standard (Desktop Experience).
- VirtualBox VM: 8GB RAM, 4 CPU cores, 60GB virtual disk, Internal Network (intnet).

##Static IP Configuration
- IP: 192.168.10.1 / 255.255.255.0 (Basic private IP address in the class C range).
- DNS: 127.0.0.0.1 (Referencing self, will function as a DNS server).

##Installation Steps
- Installed Active Directory Domain Services through the Add Roles and Features function under Server Manager (Automatically pulled in the pre-configured DNS server for AD DS to function).
- Promoted the server to domain controller, added a new forest with the root domain corp.local
- Set DSRM password, and accepted the default NetBIOS name of CORP.
- Rebooted the system automatically, and logged back into VM with the CORP/Administrator domain showing everything worked.

##Verification
- Ran the 'dcdiag' command in Powershell with a majority of core tests passing, minus a few that are not configured or otherwise functioning given the VM environment.
- Ran the 'Get-ADDomain' command in Powershell as well to confirm a number of domain properties.

###Additional Notes
- Issue: Initially installed the AD DS role and promoted the server to domain contoller before manually configuring the static IP, subnet mask, and DNS settings. The subsequent AD DS and DNS Server didn't align with my intended scheme, and making these changes later did not propogate them correctly.
- Fix: Restored the VM from a baseline snapshot taken before any role installation, set the static IP/DNS settings with the appropriate adapter, and re-ran the AD DS installation and domain controller promotion.
- Takeaway: Retroactive reconfiguration is unlikely, always verify, and take good snapshots at different points for reliable restoration and experimentation.
