<#

.SYNOPSIS
Grabs Salesforce logs using SFDX commands

.DESCRIPTION


.EXAMPLE


.NOTES
Put some notes here.

#>
Function Get-SFDXLogs() {
    [CmdletBinding()]
    param(
        [string]$Directory = "logs",
        [int]$From = 1,
        [int]$NumThreads = 10
    )

    $indexFile = "$Directory\.logindex"
    
    if ($From) {
        $From = -1 * [Math]::Abs($From)
    }

    $today = ParseDate(Get-Date).AddDays($From)
    #get ids of all downloaded logs
    Write-Verbose "Searching for log index"
    if (!(Test-Path $indexFile)) {
        Write-Verbose "Creating log index"
        New-Item $indexFile -ItemType File -Force
    }
    Write-Verbose "Reading log index"
    $importedLogIds = Get-Content -Path $indexFile

    # get metadata for all the logs
    $apiOutput = (sfdx force:apex:log:list --json | ConvertFrom-Json).result
    # put newest logs first
    [array]::Reverse($apiOutput)
    # get logs newer than input date
    $myLogList = $apiOutput | Where-Object { (ParseDate($_.StartTime) ?? $today) -ge $today }
    
    # get all ids for these logs
    $myLogIds = $myLogList | Select-Object -Property Id

    # DL all your logs from the server
    $myLogIds | ForEach-Object -Parallel {
        if (!($_.Id -in $importedLogIds)) {
            sfdx force:apex:log:get -i $_.Id -d $using:Directory
            Add-Content -Path $using:indexFile -Value $_.Id
        }
    } -ThrottleLimit $NumThreads
}

Function ParseDate () {
    param(
        [string]$Date
    )
    $DateTimeFormat = "MM/dd/yyyy H:mm:ss"
    return [datetime]::parseexact($Date, $DateTimeFormat, $null)
}

Export-ModuleMember -Function Get-SFDXLogs