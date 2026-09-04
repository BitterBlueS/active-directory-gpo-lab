# Group Policy: Workstation Hardening

## Approach
I used Microsoft's Security Compliance Toolkit (SCT) Windows 11, version 25H2 security baseline rather than hand-configuring individual settings. A vetted industry-standard baseline is more defensible and consistent than manually guessing at settings. Verified client OS version (winver > 25H2) before download the appropriate basline package, since releases are version-specific

## Import Process
- Created empty GPO: Workstation-Hardening-Baseline
- Selected "MSFT Windows 11 25H2 - Computer" as the source GPO (skipped Bitlocker/User/Domain Security baselines bundled in the same package as they are beyond the scope of this lab)
- Used "Copy identically from source" for the migration section of the wizard, basline GPOs contain no domain-specific security principlas or UNC paths requiring translation
- Linked GPO to the Workstations OU

## Verification
- Checked Local Security Policy / Advaned Audit Policy Configuration directly on the client and confirmed real configured values
- Utilizing gpresult /h HTML report did not reliably display the applied settings of the GPO despite my confirmed successful application and manual review of different security settings

## Additional Notes
- Issue: GPO import repeatedly failed with "The system cannot find the file specified," further referencing a specific missing setting file 'GptTmpl.inf' inside the extracted baseline package
- Diagnosis: Traced back to the original extraction on the host, a "path too long" prompt had appeared during the unzip process and it was accidentally dismissed with Skip instead of the retry button. The same issue was identifiable after recovering the original zip and trying to unzip it once again.
- Fix: Re-extracted the baseline package to a shorter root path on my host system desktop rather than where it was before to stay well within Windows path length limitations, and I verified the presence of critical files 'GptTmpl.inf and registry.pol' before moving it to the shared folder between the vm and my host system. The subsequent import process worked without issue
- Takeaway: It was unwise to click so quickly through the extracting warning and not register that what should have been the retry button was in fact the skip button, resulting in those files being omitted from extraction. If the source file is from a reputable source and expected to contain everything necessary it is worth checking whether there was some issue with extraction rather than troubleshooting immediately at the point of failure rather than the beginning of the chain

- Issue: After the successful import of the Windows 11 baseline settings, a manual review of the passwordl policy settings in the GPO showed a 'Not Defined' value, intially suggesting to me that the import process had not actually been successful
- Diagnosis: Checked other setting categories (Audit Policy, Administrative Templates) after numerous attempts at troubleshooting if there was an issue in the wizard and it showed that I was mistaken that it has failed, several configured values were real and had been changed
- Cause: Microsoft's security baseline excludes Account Policies like (password/lockout policy) from the Computer baseline, since that category of settings is effectively configurable at the domain level via default domain policy and fine-grained password policies
- Takeaway: Confirming a tool's intended scope matters before treating a singular instance or empty result as a bug or complete failure, unpopulated settings may exist by design rather than evidence of a failed configuration

## Key Takeaways
Importing a vetted baseline (rather than hand-building the settings from scratch) is a useful approach for maintaining industry-standard hardening practicies, but the baseline is nothing more than a baseline that requires direct verification of the applied settings and further modification to meet the individual needs of an organization.

