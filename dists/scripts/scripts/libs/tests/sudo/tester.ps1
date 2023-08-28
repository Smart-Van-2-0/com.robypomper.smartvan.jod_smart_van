
param ([switch] $FORCE=$false)

                #JOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
                #source "$JOD_DIR/scripts/libs/include.sh" "$JOD_DIR"
$PS_DIR=(get-item $PSScriptRoot ).Parent.Parent.FullName
#.$JOD_DIR/scripts/libs/include.ps1 "$JOD_DIR"
.$PS_DIR/powershell.ps1
.$PS_DIR/logs.ps1
.$PS_DIR/filesAndDirs.ps1
.$PS_DIR/hostAndOS.ps1
.$PS_DIR/sudo.ps1

                ##DEBUG=true
                #[ "$NO_LOGS" = "true" ] && setupLogsNone || [[ ! -z "$DEBUG" && "$DEBUG" == true ]] && setupLogsDebug || setupLogs
#$DEBUG=$true
if (($null -ne $DEBUG) -and ($DEBUG)) { INSTALL-LogsDebug } else { INSTALL-Logs }

                #setupCallerAndScript "$0" "${BASH_SOURCE[0]}"
setupCallerAndScript $PSCommandPath $MyInvocation.PSCommandPath

###############################################################################
logScriptInit

# Init FORCE
                #FORCE=${2:-false}
logScriptParam "FORCE" "$FORCE"

# Check current OS
failOnWrongOS

###############################################################################
logScriptRun

# Call script

logInf "### _cmd.ps1..."
$exitSudo=sudo "$PS_DIR/tests/sudo/_cmd.ps1"
if ($exitSudo -ne 0) { logFat "Failed sudo _cmd.ps1 ($exitSudo!=0)" }

logInf "### _cmd.ps1 -NO_LOGS..."
$exitSudo=sudo "$PS_DIR/tests/sudo/_cmd.ps1" -NO_LOGS
if ($exitSudo -ne 0) { logFat "Failed sudo _cmd.ps1 -NO_LOGS ($exitSudo!=0)" }
if ($Env:SUDO_OUT -ne "Script _cmd.ps1") { logFat "Failed sudo _cmd.ps1 -NO_LOGS (Env:SUDO_OUT!=Script _cmd.ps1)" }


# Call script with params

logInf "### _cmd_Params.ps1 -StrParam 'ciao belli'..."
$exitSudo=sudo "$PS_DIR/tests/sudo/_cmd_Params.ps1" -StrParam 'ciao belli'
if ($exitSudo -ne 0) { logFat "Failed sudo _cmd_Params.ps1 -StrParam 'ciao belli' ($exitSudo!=0)" }

logInf "### _cmd_Params.ps1 -NO_LOGS -StrParam 'ciao belli'..."
$exitSudo=sudo "$PS_DIR/tests/sudo/_cmd_Params.ps1" -NO_LOGS -StrParam "ciao belli"
if ($exitSudo -ne 0) { logFat "Failed sudo _cmd_Params.ps1 -NO_LOGS -StrParam 'ciao belli' ($exitSudo!=0)" }

logInf "### _cmd_Params.ps1 -NO_LOGS -StrParam 'ciao belli' -StrParam2 'not default'..."
$exitSudo=sudo "$PS_DIR/tests/sudo/_cmd_Params.ps1" -NO_LOGS -StrParam "ciao belli" -StrParam2 'not default'
if ($exitSudo -ne 0) { logFat "Failed sudo _cmd_Params.ps1 -NO_LOGS -StrParam 'ciao belli' -StrParam2 'not default' ($exitSudo!=0)" }


# Called script exit not 0 (Error: $SUDO_ERR_EXEC_SCRIPT)

logInf "### _cmd_ExitFail.ps1..."
$exitSudo=sudo "$PS_DIR/tests/sudo/_cmd_ExitFail.ps1"
if ($exitSudo -ne $SUDO_ERR_EXEC_SCRIPT) { logFat "Failed sudo _cmd_ExitFail.ps1 ($exitSudo!$SUDO_ERR_EXEC_SCRIPT0)" }

logInf "### _cmd_ExitFail.ps1 -NO_LOGS..."
$exitSudo=sudo "$PS_DIR/tests/sudo/_cmd_ExitFail.ps1" -NO_LOGS
if ($exitSudo -ne $SUDO_ERR_EXEC_SCRIPT) { logFat "Failed sudo _cmd_ExitFail.ps1 -NO_LOGS ($exitSudo!=$SUDO_ERR_EXEC_SCRIPT)" }


# Called script not found (Error: $SUDO_ERR_SCRIPT_NOT_FOUND)

logInf "### _cmd_NotFound.ps1..."
$exitSudo=sudo "$PS_DIR/tests/sudo/_cmd_NotFound.ps1"
if ($exitSudo -ne $SUDO_ERR_SCRIPT_NOT_FOUND) { logFat "Failed sudo _cmd_NotFound.ps1 ($exitSudo!=$SUDO_ERR_SCRIPT_NOT_FOUND)" }

logInf "### _cmd_NotFound.ps1 -NO_LOGS..."
$exitSudo=sudo "$PS_DIR/tests/sudo/_cmd_NotFound.ps1" -NO_LOGS
if ($exitSudo -ne $SUDO_ERR_SCRIPT_NOT_FOUND) { logFat "Failed sudo _cmd_NotFound.ps1 -NO_LOGS ($exitSudo!=$SUDO_ERR_SCRIPT_NOT_FOUND)" }


###############################################################################
logScriptEnd
