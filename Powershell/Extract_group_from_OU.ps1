#------------------------------------------------------------------------------
# Script Name: Export-ADGroups.ps1
# Description: This script exports Active Directory groups from a specific Organizational Unit (OU) and saves the information into a CSV file.
# Author: Anonymized
# Version: 1.0
# Date: 2024-09-17
# Usage: Requires the Active Directory module to be installed and the appropriate permissions
#        to query Active Directory groups.
#------------------------------------------------------------------------------

# Variables
$OUPath = "OU=Anonymous,DC=domain,DC=tld"  # Replaced with OU path
$CsvPath = "C:\temp\group_export.csv"  # export path
$Server = "DC.domain.tld"  # AD server name

# Export Active Directory groups
Get-ADGroup -Filter * `
    -Properties * `
    -SearchBase $OUPath `
    -Server $Server | 
    Select-Object Name, DistinguishedName | 
    Export-Csv -Path $CsvPath `
               -NoTypeInformation `
               -Append `
               -Encoding UTF8
