<#
.SYNOPSIS
    Retrieves the hostname of the Domain Controllers holding the PDC Emulator role for each domain in the Active Directory forest.

.DESCRIPTION
    This script iterates through all domains in the Active Directory forest and retrieves the hostname of the Domain Controller that holds the PDC Emulator role for each domain.
    It outputs only the hostname without the FQDN.

.PARAMETERS
    None

.EXAMPLE
    .\Get-PDCEmulatorHostnames.ps1

.NOTES
    Author: Anonymized
    Creation Date: 2024-06-25
    Version: 1.0
#>

# Import the Active Directory module
Import-Module ActiveDirectory

# Retrieve all domains from the forest
$domains = (Get-ADForest).Domains

foreach ($domain in $domains) {
    try {
        # Get domain information
        $domainObject = Get-ADDomain -Server $domain
        
        # Get the Domain Controller with the PDC Emulator role for each domain
        $pdcEmulator = $domainObject.PDCEmulator
        
        # Extract the hostname without the FQDN
        $hostname = $pdcEmulator.Split('.')[0]
        
        # Output the hostname without the FQDN
        Write-Output $hostname
    } catch {
        Write-Output "Error retrieving the PDC Emulator for the domain $domain: $_"
    }
}
