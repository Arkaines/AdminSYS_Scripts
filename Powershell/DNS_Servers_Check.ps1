# ================================
# Script Name: DNS Check Script for Multiple Servers with CSV Report Generation
# Description: This PowerShell script verifies DNS configurations across multiple servers and generates a CSV report with the results.
# Author: Anonymized
# Version: 1.0
# Date: 2024-09-17
# ================================

# Step 1: Define variables
$serverListPath = "C:\Path\To\ServerList.txt"  # Replace with the path to your server list file
$outputCsvPath = "C:\Path\To\Output\DNS_Report.csv"  # Replace with the path for the output CSV file

# Check if the server list file exists
if (-not (Test-Path -Path $serverListPath)) {
    Write-Output "The server list file does not exist: $serverListPath"
    return
}

# Read the server list
$servers = Get-Content -Path $serverListPath

# Initialize a list to store the results
$results = @()

# Script to execute on each remote server
$scriptBlock = {
    param($newDnsServer)

    try {
        # Check if the 'Get-DnsClientServerAddress' command is available
        if (-not (Get-Command -Name 'Get-DnsClientServerAddress' -ErrorAction SilentlyContinue)) {
            # Use WMI if the command is not available
            $netAdapters = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true -and $_.DNSServerSearchOrder -ne $null }

            # Check if any network interfaces with configured DNS are found
            if ($netAdapters.Count -eq 0) {
                return "No network interface with configured DNS servers found."
            }

            # Loop through each network interface found and retrieve DNS servers
            $dnsInfo = ""
            foreach ($adapter in $netAdapters) {
                $dnsInfo += "Interface: $($adapter.Description), DNS Servers: $($adapter.DNSServerSearchOrder -join ', ')" + "`n"
            }
            return $dnsInfo.Trim()
        } else {
            # Use PowerShell DNS cmdlets if the command is available
            $dnsConfiguredInterfaces = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object {
                $_.ServerAddresses.Count -gt 0
            }

            # Check if any interfaces with configured DNS were found
            if (-not $dnsConfiguredInterfaces) {
                return "No interface with configured DNS servers found."
            }

            # Loop through each interface and retrieve DNS servers
            $dnsInfo = ""
            foreach ($interface in $dnsConfiguredInterfaces) {
                $dnsInfo += "Interface: $($interface.InterfaceAlias), DNS Servers: $($interface.ServerAddresses -join ', ')" + "`n"
            }
            return $dnsInfo.Trim()
        }
    } catch {
        return "Error: $_"
    }
}

# Step 3: Execute the script on each server
foreach ($server in $servers) {
    Write-Output "Connecting to $server..."
    $result = ""

    try {
        $result = Invoke-Command -ComputerName $server -ScriptBlock $scriptBlock -ErrorAction Stop
        $status = if ($result -like "Error*") { "Failed" } else { "Success" }
    } catch {
        $result = "Error executing script on $server: $_"
        $status = "Failed"
    }

    # Add results to the array
    $results += [PSCustomObject]@{
        Server  = $server
        Status  = $status
        DNSInfo = $result
    }
}

# Step 4: Export results to a CSV file
$results | Export-Csv -Path $outputCsvPath -NoTypeInformation -Encoding UTF8

Write-Output "Report successfully generated: $outputCsvPath"
