# SFDX_Log_Pull
Small script I wrote to pull Salesforce logs from their cloud environment.  The log files get written into a directory and can be searched locally using your language of choice or imported into an elastic instance.

# Requirements:
1. SFDX powershell library
2. Powershell 7

# Steps
1. Authorize an org using sfdx
2. Run `Get-SFDXLogs` in same folder as authorized org

# Notes

- The default directory is `.\logs` and can be changed using the `-Directory` parameter.

- The default number of parallel threads is `10` and can be changed using the `-NumThreads` parameter

- The default number of days the job looks back is `1` and can be changed using the `-From` parameter

- `\logs\.logindex` contains a list of all of the logs that have been pulled from SalesForce.