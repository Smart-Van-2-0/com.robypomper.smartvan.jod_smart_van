param (
        [Parameter(Mandatory=$true)][string]$StrParam,
        [Parameter(Mandatory=$false)][string]$StrParam2="DEFAULT",
        [switch] $NO_LOGS=$false
    )

$msg = "Script _cmd_Params.ps1 -StrParam '$StrParam' -StrParam2 '$StrParam2' -NO_LOGS='$NO_LOGS'"
$msg
# or Write-Host $msg

exit 0