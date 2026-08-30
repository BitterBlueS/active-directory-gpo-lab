# Group Policy: Password Policy

## Default Domain Policy (baseline)
Reviewed via Group Policy Management > Default Domain Policy > Computer Configuration > Policies > Windiws Settings > Security Settings > Account Policies > Password Policy.

-Minimum password length: 7 (default)
-Password history: 24 (default)
-Complexity requirements: enabled (default)
-Applies domain-wide - a single Default Domain Policy cannot have different settings per OU or group without a separate mechanism, hence the OU specific password policy below

## Enhanced Password Policy (PSO) : IT-Strict-Password-Policy
Created via Active Ditectory Administrative Center > System > Password Settings Container > New > Password Settings.

-Name: IT-Strict-Password-Policy
-Precedence: 10
-Minimum password length: 14
-Password history: 24
-Maximum password age: 60 days
-Complexity requirements: enabled
-Applies to: IT-Staff group (Directly to the security group, not the IT OU itself as the PSO only applies to users/groups which differs significantly from other processes like standard GPO linking)

## Testing
-Attempted a password change under 14 characters for SWinters (IT-Staff member) and was rejected, as expected under the stricter PSO overriding default windows security settings
-Attempted the same short password for a Sales user not in the (IT-Staff group) and was accepted, as the the less strict Default Domain Policy is in effect

## Verification
-Ran the powershell command 'Get-ADUserResultantPasswordPolicy -Identity SWinters' which returned 'IT-Strict-Password-Policy' as the resultant policy for SWinters, correctly overriding the domain defaults for IT-Staff group members.

### Takeaways
PSOs apply directly to users or groups, not OUs which seems quite easy to mix up. Precendence determines which PSO wins if a users is a member of multiple groups with different PSOs applied.

