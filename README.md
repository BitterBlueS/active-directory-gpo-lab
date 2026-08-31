# Active Directory & Group Policy Lab

Windows Server domain lab simulating help desk/system admin workflows - active directory provisioning, group policy hardening, and runbook documentation.

Built it as a self-directed project to develop hands-on experience with core sysadmin/help desk tasks: provisioning users, groups, and OUs; deploying Group Policy Objects for password enforcement, application restriction, and workstation hardening; and producing runbook-style documentation for common help desk workflows.

## Environment
- Windows Server 2022 Standard (Desktop Experience) Domain Controller
- Windows 11 Enterprise (evaulation) domain-joined client system
- Virtualbox, isolated internal network (no host/internet exposure)

## Contents
Build Documentation
- [DC Setup](doc/01-DC-setup.md)
- [Client Join](doc/02-Client-join.md)
- [OU Structure & User Provisioning](doc/03-OU-and-users.md)
- [Group Policy: Password Policy](doc/04a-Password-policy.md)
- [Group Policy: Software Restriction (AppLocker)](doc/04b-Software-restriction.md)
- [Group Policy: Workstation Hardening](doc/04c-Workstation-hardening.md)

Runbooks
- [Runbook: Onboarding](doc/runbook-onboarding.md)
- [Runbook: Access Change](doc/runbook-access-change.md)
- [Runbook: Workstation Hardening](doc/runbook-auth-troubleshooting.md)

Scripts
- [General User Provisioning](scripts/general-onboarding.ps1)

## What This Covers
- User/group/OU provisioning: manual and bulk (PowerShell + CSV) account creation, OU design, security group scoping
- Group Policy: a domain-wide password baseline plus a Fine-Grained password policy scoped to a specific group; AppLocker-based application restriction; a Microsoft Security Compliance Toolkit hardening baseline
- Documentation: each build phase includes real setup steps and actual issues encountered along the way (not idealized writeups), plus three help desk-style runbooks derived from my experiences

### Status
Complete



