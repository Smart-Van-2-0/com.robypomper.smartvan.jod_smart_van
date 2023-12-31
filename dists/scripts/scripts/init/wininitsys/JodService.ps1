###############################################################################
#                                                                             #
#   File name       PSService.ps1                                             #
#                                                                             #
#   Description     A sample service in a standalone PowerShell script        #
#                                                                             #
#   Notes           The latest PSService.ps1 version is available in GitHub   #
#                   repository https://github.com/JFLarvoire/SysToolsLib/ ,   #
#                   in the PowerShell subdirectory.                           #
#                   Please report any problem in the Issues tab in that       #
#                   GitHub repository in                                      #
#                   https://github.com/JFLarvoire/SysToolsLib/issues          #
#                   If you do submit a pull request, please add a comment at  #
#                   the end of this header with the date, your initials, and  #
#                   a description of the changes. Also update $scriptVersion. #
#                                                                             #
#                   The initial version of this script was described in an    #
#                   article published in the May 2016 issue of MSDN Magazine. #
#                   https://msdn.microsoft.com/en-us/magazine/mt703436.aspx   #
#                   This updated version has one major change:                #
#                   The -Service handler in the end has been rewritten to be  #
#                   event-driven, with a second thread waiting for control    #
#                   messages coming in via a named pipe.                      #
#                   This allows fixing a bug of the original version, that    #
#                   did not stop properly, and left a zombie process behind.  #
#                   The drawback is that the new code is significantly longer,#
#                   due to the added PowerShell thread management routines.   #
#                   On the other hand, these thread management routines are   #
#                   reusable, and will allow building much more powerful      #
#                   services.                                                 #
#                                                                             #
#                   Dynamically generates a small PSService.exe wrapper       #
#                   application, that in turn invokes this PowerShell script. #
#                                                                             #
#                   Some arguments are inspired by Linux' service management  #
#                   arguments: -Start, -Stop, -Restart, -Status               #
#                   Others are more in the Windows' style: -Setup, -Remove    #
#                                                                             #
#                   The actual start and stop operations are done when        #
#                   running as SYSTEM, under the control of the SCM (Service  #
#                   Control Manager).                                         #
#                                                                             #
#                   To create your own service, make a copy of this file and  #
#                   rename it. The file base name becomes the service name.   #
#                   Then implement your own service code in the if ($Service) #
#                   {block} at the very end of this file. See the TO DO       #
#                   comment there.                                            #
#                   There are global settings below the script param() block. #
#                   They can easily be changed, but the defaults should be    #
#                   suitable for most projects.                               #
#                                                                             #
#                   Service installation and usage: See the dynamic help      #
#                   section below, or run: help .\PSService.ps1 -Detailed     #
#                                                                             #
#                   Debugging: The Log function writes messages into a file   #
#                   called C:\Windows\Logs\PSService.log (or actually         #
#                   ${env:windir}\Logs\$serviceName.log).                     #
#                   It is very convenient to monitor what's written into that #
#                   file with a WIN32 port of the Unix tail program. Usage:   #
#                   tail -f C:\Windows\Logs\PSService.log                     #
#                                                                             #
#   History                                                                   #
#    2015-07-10 JFL jf.larvoire@hpe.com created this script.                  #
#    2015-10-13 JFL Made this script completely generic, and added comments   #
#                   in the header above.                                      #
#    2016-01-02 JFL Moved the Event Log name into new variable $logName.      #
#                   Improved comments.                                        #
#    2016-01-05 JFL Fixed the StartPending state reporting.                   #
#    2016-03-17 JFL Removed aliases. Added missing explicit argument names.   #
#    2016-04-16 JFL Moved the official repository on GitHub.                  #
#    2016-04-21 JFL Minor bug fix: New-EventLog did not use variable $logName.#
#    2016-05-25 JFL Bug fix: The service task was not properly stopped; Its   #
#                   finally block was not executed, and a zombie task often   #
#                   remained. Fixed by using a named pipe to send messages    #
#                   to the service task.                                      #
#    2016-06-05 JFL Finalized the event-driven service handler.               #
#                   Fixed the default command setting in PowerShell v2.       #
#                   Added a sample -Control option using the new pipe.        #
#    2016-06-08 JFL Rewrote the pipe handler using PSThreads instead of Jobs. #
#    2016-06-09 JFL Finalized the PSThread management routines error handling.#
#                   This finally fixes issue #1.                              #
#    2016-08-22 JFL Fixed issue #3 creating the log and install directories.  #
#                   Thanks Nischl.                                            #
#    2016-09-06 JFL Fixed issue #4 detecting the System account. Now done in  #
#                   a language-independent way. Thanks A Gonzalez.            #
#    2016-09-19 JFL Fixed issue #5 starting services that begin with a number.#
#                   Added a $ServiceDescription string global setting, and    #
#                   use it for the service registration.                      #
#                   Added comments about Windows event logs limitations.      #
#    2016-11-17 RBM Fixed issue #6 Mangled hyphen in final Unregister-Event.  #
#    2017-05-10 CJG Added execution policy bypass flag.                       #
#    2017-10-04 RBL rblindberg Updated C# code OnStop() routine fixing        #
#                   orphaned process left after stoping the service.          #
#    2017-12-05 NWK omrsafetyo Added ServiceUser and ServicePassword to the   #
#                   script parameters.                                        #
#    2017-12-10 JFL Removed the unreliable service account detection tests,   #
#                   and instead use dedicated -SCMStart and -SCMStop          #
#                   arguments in the PSService.exe helper app.                #
#                   Renamed variable userName as currentUserName.             #
#                   Renamed arguments ServiceUser and ServicePassword to the  #
#                   more standard UserName and Password.                      #
#                   Also added the standard argument -Credential.             #
#    2021-09-09 RBP Added ServiceId param to handle multiple services from    #
#                   the same PowerShell script                                #
#                                                                             #
###############################################################################
#Requires -version 2

<#
  .SYNOPSIS
    A sample Windows service, in a standalone PowerShell script.

  .DESCRIPTION
    This script demonstrates how to write a Windows service in pure PowerShell.
    It dynamically generates a small PSService.exe wrapper, that in turn
    invokes this PowerShell script again for its start and stop events.

  .PARAMETER Start
    Start the service.

  .PARAMETER Stop
    Stop the service.

  .PARAMETER Restart
    Stop then restart the service.

  .PARAMETER Status
    Get the current service status: Not installed / Stopped / Running

  .PARAMETER Setup
    Install the service.
    Optionally use the -Credential or -UserName arguments to specify the user
    account for running the service. By default, uses the LocalSystem account.
    Known limitation with the old PowerShell v2: It is necessary to use -Credential
    or -UserName. For example, use -UserName LocalSystem to emulate the v3+ default.

  .PARAMETER Credential
    User and password credential to use for running the service.
    For use with the -Setup command.
    Generate a PSCredential variable with the Get-Credential command.

  .PARAMETER UserName
    User account to use for running the service.
    For use with the -Setup command, in the absence of a Credential variable.
    The user must have the "Log on as a service" right. To give him that right,
    open the Local Security Policy management console, go to the
    "\Security Settings\Local Policies\User Rights Assignments" folder, and edit
    the "Log on as a service" policy there.
    Services should always run using a user account which has the least amount
    of privileges necessary to do its job.
    Three accounts are special, and do not require a password:
    * LocalSystem - The default if no user is specified. Highly privileged.
    * LocalService - Very few privileges, lowest security risk.
      Apparently not enough privileges for running PowerShell. Do not use.
    * NetworkService - Idem, plus network access. Same problems as LocalService.

  .PARAMETER Password
    Password for UserName. If not specified, you will be prompted for it.
    It is strongly recommended NOT to use that argument, as that password is
    visible on the console, and in the task manager list.
    Instead, use the -UserName argument alone, and wait for the prompt;
    or, even better, use the -Credential argument.

  .PARAMETER Remove
    Uninstall the service.

  .PARAMETER Service
    Run the service in the background. Used internally by the script.
    Do not use, except for test purposes.

  .PARAMETER SCMStart
    Process Service Control Manager start requests. Used internally by the script.
    Do not use, except for test purposes.

  .PARAMETER SCMStop
    Process Service Control Manager stop requests. Used internally by the script.
    Do not use, except for test purposes.

  .PARAMETER Control
    Send a control message to the service thread.

  .PARAMETER Version
    Display this script version and exit.

  .PARAMETER ServiceID
    Customize the service name (as unique service id across current windows services)

  .EXAMPLE
    # Setup the service and run it for the first time
    C:\PS>.\PSService.ps1 -Status
    Not installed
    C:\PS>.\PSService.ps1 -Setup
    C:\PS># At this stage, a copy of PSService.ps1 is present in the path
    C:\PS>PSService -Status
    Stopped
    C:\PS>PSService -Start
    C:\PS>PSService -Status
    Running
    C:\PS># Load the log file in Notepad.exe for review
    C:\PS>notepad ${ENV:windir}\Logs\PSService.log

  .EXAMPLE
    # Stop the service and uninstall it.
    C:\PS>PSService -Stop
    C:\PS>PSService -Status
    Stopped
    C:\PS>PSService -Remove
    C:\PS># At this stage, no copy of PSService.ps1 is present in the path anymore
    C:\PS>.\PSService.ps1 -Status
    Not installed

  .EXAMPLE
    # Configure the service to run as a different user
    C:\PS>$cred = Get-Credential -UserName LAB\Assistant
    C:\PS>.\PSService -Setup -Credential $cred

  .EXAMPLE
    # Send a control message to the service, and verify that it received it.
    C:\PS>PSService -Control Hello
    C:\PS>Notepad C:\Windows\Logs\PSService.log
    # The last lines should contain a trace of the reception of this Hello message

  .EXAMPLE
    # Setup 2 services from the same script
    C:\PS>.\PSService.ps1 -ServiceId "ServiceA" -Status
    Not installed
    C:\PS>.\PSService.ps1 -ServiceId "ServiceA" -Setup
    C:\PS>.\PSService.ps1 -ServiceId "ServiceB" -Setup
    C:\PS># At this stage, a 2 copies of PSService.ps1 is present in the path as "ServiceA.ps1" and "ServiceB.ps1"
    C:\PS>PSService -ServiceId "ServiceA" -Status
    Stopped
    C:\PS>PSService -ServiceId "ServiceB" -Status
    Stopped
    C:\PS># Run only ServiceA
    C:\PS>PSService -ServiceId "ServiceA" -Start
    C:\PS>PSService -ServiceId "ServiceA" -Status
    Running
    C:\PS>PSService -ServiceId "ServiceB" -Status
    Stopped
    C:\PS># Run also ServiceB
    C:\PS>PSService -ServiceId "ServiceB" -Start
    C:\PS>PSService -ServiceId "ServiceA" -Status
    Running
    C:\PS>PSService -ServiceId "ServiceB" -Status
    Running
    C:\PS># Load the log file in Notepad.exe for review
    C:\PS>notepad ${ENV:windir}\Logs\ServiceA.log
    C:\PS>notepad ${ENV:windir}\Logs\ServiceB.log
#>

[CmdletBinding(DefaultParameterSetName='Status')]
Param(
  [Parameter(ParameterSetName='Start', Mandatory=$true)]
  [Switch]$Start,               # Start the service

  [Parameter(ParameterSetName='Stop', Mandatory=$true)]
  [Switch]$Stop,                # Stop the service

  [Parameter(ParameterSetName='Restart', Mandatory=$true)]
  [Switch]$Restart,             # Restart the service

  [Parameter(ParameterSetName='Status', Mandatory=$false)]
  [Switch]$Status = $($PSCmdlet.ParameterSetName -eq 'Status'), # Get the current service status

  [Parameter(ParameterSetName='Setup', Mandatory=$true)]
  [Parameter(ParameterSetName='Setup2', Mandatory=$true)]
  [Switch]$Setup,               # Install the service

  [Parameter(ParameterSetName='Setup', Mandatory=$true)]
  [String]$UserName,              # Set the service to run as this user
  
  [Parameter(ParameterSetName='Setup', Mandatory=$false)]
  [String]$Password,              # Use this password for the user
  
  [Parameter(ParameterSetName='Setup2', Mandatory=$false)]
  [System.Management.Automation.PSCredential]$Credential, # Service account credential

  [Parameter(ParameterSetName='Remove', Mandatory=$true)]
  [Switch]$Remove,              # Uninstall the service

  [Parameter(ParameterSetName='Service', Mandatory=$true)]
  [Switch]$Service,               # Run the service (Internal use only)

  [Parameter(ParameterSetName='SCMStart', Mandatory=$true)]
  [Switch]$SCMStart,              # Process SCM Start requests (Internal use only)

  [Parameter(ParameterSetName='SCMStop', Mandatory=$true)]
  [Switch]$SCMStop,               # Process SCM Stop requests (Internal use only)

  [Parameter(ParameterSetName='Control', Mandatory=$true)]
  [String]$Control = $null,     # Control message to send to the service

  [Parameter(ParameterSetName='Version', Mandatory=$true)]
  [Switch]$Version,             # Get this script version

  [Parameter(ParameterSetName='GetPID', Mandatory=$true)]
  [Switch]$GetPID,              # Get the pid of java instance for this service

  [Parameter(ParameterSetName='GetPIDScript', Mandatory=$true)]
  [Switch]$GetPIDScript,        # Get the pid of powershell script for this service

  [Parameter(ParameterSetName='GetPIDExec', Mandatory=$true)]
  [Switch]$GetPIDExec,          # Get the pid of exec instance for this service

  [Parameter(ParameterSetName='GetPIDAll', Mandatory=$true)]
  [Switch]$GetPIDAll,           # Get the all pids of java, script and exec instance for this service

  [Parameter(Mandatory=$false)]
  [string]$ServiceID            # Set service name (unique id across all system services)
)

$scriptVersion = "2017-12-10_josp-0.1"

# This script name, with various levels of details
$argv0 = Get-Item $MyInvocation.MyCommand.Definition
$script = $argv0.basename               # Ex: PSService
$scriptName = $argv0.name               # Ex: PSService.ps1
$scriptFullName = $argv0.fullname       # Ex: C:\Temp\PSService.ps1
$scriptPath = $PSScriptRoot             # Ex: C:\Temp

# Parametrized settings
if ($ServiceId -eq "") {$ServiceId=$script}

# Global settings
$jodDir="$scriptPath/../../.."
$serviceName = $ServiceId               # A one-word name used for net start commands
$serviceDisplayName = "The JOD service for '$serviceName' installation"
$ServiceDescription = "Shows how a service can be written in PowerShell"
$pipeName = "Service_$serviceName"      # Named pipe name. Used for sending messages to the service task
# $installDir = "${ENV:ProgramFiles}\$serviceName" # Where to install the service files
$installDir = "${ENV:windir}\System32"  # Where to install the service files
$scriptCopy = "$installDir\$serviceName.ps1"
$exeName = "$serviceName.exe"
$exeFullName = "$installDir\$exeName"
#$logDir = "${ENV:windir}\Logs"          # Where to log the service messages
$logDir = "$jodDir\logs"
$logFile = "$logDir\$serviceName.log"
$logName = "Application"                # Event Log name (Unrelated to the logFile!)
# Note: The current implementation only supports "classic" (ie. XP-compatble) event logs.
#	To support new style (Vista and later) "Applications and Services Logs" folder trees, it would
#	be necessary to use the new *WinEvent commands instead of the XP-compatible *EventLog commands.
# Gotcha: If you change $logName to "NEWLOGNAME", make sure that the registry key below does not exist:
#         HKLM\System\CurrentControlSet\services\eventlog\Application\NEWLOGNAME
#	  Else, New-EventLog will fail, saying the log NEWLOGNAME is already registered as a source,
#	  even though "Get-WinEvent -ListLog NEWLOGNAME" says this log does not exist!

Set-Location $scriptPath

# If the -Version switch is specified, display the script version and exit.
if ($Version) {
  Write-Output $scriptVersion
  return
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Now                                                       #
#                                                                             #
#   Description     Get a string with the current time.                       #
#                                                                             #
#   Notes           The output string is in the ISO 8601 format, except for   #
#                   a space instead of a T between the date and time, to      #
#                   improve the readability.                                  #
#                                                                             #
#   History                                                                   #
#    2015-06-11 JFL Created this routine.                                     #
#                                                                             #
#-----------------------------------------------------------------------------#

Function Now {
  Param (
    [Switch]$ms,        # Append milliseconds
    [Switch]$ns         # Append nanoseconds
  )
  $Date = Get-Date
  $now = ""
  $now += "{0:0000}-{1:00}-{2:00} " -f $Date.Year, $Date.Month, $Date.Day
  $now += "{0:00}:{1:00}:{2:00}" -f $Date.Hour, $Date.Minute, $Date.Second
  $nsSuffix = ""
  if ($ns) {
    if ("$($Date.TimeOfDay)" -match "\.\d\d\d\d\d\d") {
      $now += $matches[0]
      $ms = $false
    } else {
      $ms = $true
      $nsSuffix = "000"
    }
  } 
  if ($ms) {
    $now += ".{0:000}$nsSuffix" -f $Date.MilliSecond
  }
  return $now
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Log                                                       #
#                                                                             #
#   Description     Log a string into the PSService.log file                  #
#                                                                             #
#   Arguments       A string                                                  #
#                                                                             #
#   Notes           Prefixes the string with a timestamp and the user name.   #
#                   (Except if the string is empty: Then output a blank line.)#
#                                                                             #
#   History                                                                   #
#    2016-06-05 JFL Also prepend the Process ID.                              #
#    2016-06-08 JFL Allow outputing blank lines.                              #
#                                                                             #
#-----------------------------------------------------------------------------#

Function Log () {
  Param(
    [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
    [String]$string
  )
  if (!(Test-Path $logDir)) {
    New-Item -ItemType directory -Path $logDir | Out-Null
  }
  $pidStr=([string]$PID).PadLeft(5," ")
  $usrStr=$currentUserName.SubString($currentUserName.IndexOf("\")+1).PadRight(10,' ')
  if ($String.length) {
    $stringFormatted = "$(Now) [$pidStr-$usrStr]  $string"
  }
  try {
    Write-Verbose "$(Now) [$pidStr] $string"
    $stringFormatted | Out-File -Encoding ASCII -Append "$logFile"
  } catch {
    Write-Verbose "$(Now) [$pidStr] Exception on writing to log file"
  }

}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Start-PSThread                                            #
#                                                                             #
#   Description     Start a new PowerShell thread                             #
#                                                                             #
#   Arguments       See the Param() block                                     #
#                                                                             #
#   Notes           Returns a thread description object.                      #
#                   The completion can be tested in $_.Handle.IsCompleted     #
#                   Alternative: Use a thread completion event.               #
#                                                                             #
#   References                                                                #
#    https://learn-powershell.net/tag/runspace/                               #
#    https://learn-powershell.net/2013/04/19/sharing-variables-and-live-objects-between-powershell-runspaces/
#    http://www.codeproject.com/Tips/895840/Multi-Threaded-PowerShell-Cookbook
#                                                                             #
#   History                                                                   #
#    2016-06-08 JFL Created this function                                     #
#                                                                             #
#-----------------------------------------------------------------------------#

$PSThreadCount = 0              # Counter of PSThread IDs generated so far
$PSThreadList = @{}             # Existing PSThreads indexed by Id

Function Get-PSThread () {
  Param(
    [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
    [int[]]$Id = $PSThreadList.Keys     # List of thread IDs
  )
  $Id | % { $PSThreadList.$_ }
}

Function Start-PSThread () {
  Param(
    [Parameter(Mandatory=$true, Position=0)]
    [ScriptBlock]$ScriptBlock,          # The script block to run in a new thread
    [Parameter(Mandatory=$false)]
    [String]$Name = "",                 # Optional thread name. Default: "PSThread$Id"
    [Parameter(Mandatory=$false)]
    [String]$Event = "",                # Optional thread completion event name. Default: None
    [Parameter(Mandatory=$false)]
    [Hashtable]$Variables = @{},        # Optional variables to copy into the script context.
    [Parameter(Mandatory=$false)]
    [String[]]$Functions = @(),         # Optional functions to copy into the script context.
    [Parameter(Mandatory=$false)]
    [Object[]]$Arguments = @()          # Optional arguments to pass to the script.
  )

  $Id = $script:PSThreadCount
  $script:PSThreadCount += 1
  if (!$Name.Length) {
    $Name = "PSThread$Id"
  }
  $InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
  foreach ($VarName in $Variables.Keys) { # Copy the specified variables into the script initial context
    $value = $Variables.$VarName
    Write-Debug "Adding variable $VarName=[$($Value.GetType())]$Value"
    $var = New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry($VarName, $value, "")
    $InitialSessionState.Variables.Add($var)
  }
  foreach ($FuncName in $Functions) { # Copy the specified functions into the script initial context
    $Body = Get-Content function:$FuncName
    Write-Debug "Adding function $FuncName () {$Body}"
    $func = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry($FuncName, $Body)
    $InitialSessionState.Commands.Add($func)
  }
  $RunSpace = [RunspaceFactory]::CreateRunspace($InitialSessionState)
  $RunSpace.Open()
  $PSPipeline = [powershell]::Create()
  $PSPipeline.Runspace = $RunSpace
  $PSPipeline.AddScript($ScriptBlock) | Out-Null
  $Arguments | % {
    Write-Debug "Adding argument [$($_.GetType())]'$_'"
    $PSPipeline.AddArgument($_) | Out-Null
  }
  $Handle = $PSPipeline.BeginInvoke() # Start executing the script
  if ($Event.Length) { # Do this after BeginInvoke(), to avoid getting the start event.
    Register-ObjectEvent $PSPipeline -EventName InvocationStateChanged -SourceIdentifier $Name -MessageData $Event
  }
  $PSThread = New-Object PSObject -Property @{
    Id = $Id
    Name = $Name
    Event = $Event
    RunSpace = $RunSpace
    PSPipeline = $PSPipeline
    Handle = $Handle
  }     # Return the thread description variables
  $script:PSThreadList[$Id] = $PSThread
  $PSThread
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Receive-PSThread                                          #
#                                                                             #
#   Description     Get the result of a thread, and optionally clean it up    #
#                                                                             #
#   Arguments       See the Param() block                                     #
#                                                                             #
#   Notes                                                                     #
#                                                                             #
#   History                                                                   #
#    2016-06-08 JFL Created this function                                     #
#                                                                             #
#-----------------------------------------------------------------------------#

Function Receive-PSThread () {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
    [PSObject]$PSThread,                # Thread descriptor object
    [Parameter(Mandatory=$false)]
    [Switch]$AutoRemove                 # If $True, remove the PSThread object
  )
  Process {
    if ($PSThread.Event -and $AutoRemove) {
      Unregister-Event -SourceIdentifier $PSThread.Name
      Get-Event -SourceIdentifier $PSThread.Name | Remove-Event # Flush remaining events
    }
    try {
      $PSThread.PSPipeline.EndInvoke($PSThread.Handle) # Output the thread pipeline output
    } catch {
      $_ # Output the thread pipeline error
    }
    if ($AutoRemove) {
      $PSThread.RunSpace.Close()
      $PSThread.PSPipeline.Dispose()
      $PSThreadList.Remove($PSThread.Id)
    }
  }
}

Function Remove-PSThread () {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
    [PSObject]$PSThread                 # Thread descriptor object
  )
  Process {
    $_ | Receive-PSThread -AutoRemove | Out-Null
  }
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Send-PipeMessage                                          #
#                                                                             #
#   Description     Send a message to a named pipe                            #
#                                                                             #
#   Arguments       See the Param() block                                     #
#                                                                             #
#   Notes                                                                     #
#                                                                             #
#   History                                                                   #
#    2016-05-25 JFL Created this function                                     #
#                                                                             #
#-----------------------------------------------------------------------------#

Function Send-PipeMessage () {
  Param(
    [Parameter(Mandatory=$true)]
    [String]$PipeName,          # Named pipe name
    [Parameter(Mandatory=$true)]
    [String]$Message            # Message string
  )
  $PipeDir  = [System.IO.Pipes.PipeDirection]::Out
  $PipeOpt  = [System.IO.Pipes.PipeOptions]::Asynchronous

  $pipe = $null # Named pipe stream
  $sw = $null   # Stream Writer
  try {
    $pipe = new-object System.IO.Pipes.NamedPipeClientStream(".", $PipeName, $PipeDir, $PipeOpt)
    $sw = new-object System.IO.StreamWriter($pipe)
    $pipe.Connect(1000)
    if (!$pipe.IsConnected) {
      throw "Failed to connect client to pipe $pipeName"
    }
    $sw.AutoFlush = $true
    $sw.WriteLine($Message)
  } catch {
    Log "(Send-PipeMessage) Error sending pipe $pipeName message: $_"
  } finally {
    if ($sw) {
      $sw.Dispose() # Release resources
      $sw = $null   # Force the PowerShell garbage collector to delete the .net object
    }
    if ($pipe) {
      $pipe.Dispose() # Release resources
      $pipe = $null   # Force the PowerShell garbage collector to delete the .net object
    }
  }
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Receive-PipeMessage                                       #
#                                                                             #
#   Description     Wait for a message from a named pipe                      #
#                                                                             #
#   Arguments       See the Param() block                                     #
#                                                                             #
#   Notes           I tried keeping the pipe open between client connections, #
#                   but for some reason everytime the client closes his end   #
#                   of the pipe, this closes the server end as well.          #
#                   Any solution on how to fix this would make the code       #
#                   more efficient.                                           #
#                                                                             #
#   History                                                                   #
#    2016-05-25 JFL Created this function                                     #
#                                                                             #
#-----------------------------------------------------------------------------#

Function Receive-PipeMessage () {
  Param(
    [Parameter(Mandatory=$true)]
    [String]$PipeName           # Named pipe name
  )
  $PipeDir  = [System.IO.Pipes.PipeDirection]::In
  $PipeOpt  = [System.IO.Pipes.PipeOptions]::Asynchronous
  $PipeMode = [System.IO.Pipes.PipeTransmissionMode]::Message

  try {
    $pipe = $null       # Named pipe stream
    $pipe = New-Object system.IO.Pipes.NamedPipeServerStream($PipeName, $PipeDir, 1, $PipeMode, $PipeOpt)
    $sr = $null         # Stream Reader
    $sr = new-object System.IO.StreamReader($pipe)
    $pipe.WaitForConnection()
    $Message = $sr.Readline()
    $Message
  } catch {
    $msg = $_.Exception.Message
    $line = $_.InvocationInfo.ScriptLineNumber
    Log "(Receive-PipeMessage) Exception at line ${line} reading named pipe '$PipeName' for service '$serviceName': $msg"
    Log "(Receive-PipeMessage)            receiving pipe message: $_"
  } finally {
    if ($sr) {
      $sr.Dispose() # Release resources
      $sr = $null   # Force the PowerShell garbage collector to delete the .net object
    }
    if ($pipe) {
      $pipe.Dispose() # Release resources
      $pipe = $null   # Force the PowerShell garbage collector to delete the .net object
    }
  }
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Start-PipeHandlerThread                                   #
#                                                                             #
#   Description     Start a new thread waiting for control messages on a pipe #
#                                                                             #
#   Arguments       See the Param() block                                     #
#                                                                             #
#   Notes           The pipe handler script uses function Receive-PipeMessage.#
#                   This function must be copied into the thread context.     #
#                                                                             #
#                   The other functions and variables copied into that thread #
#                   context are not strictly necessary, but are useful for    #
#                   debugging possible issues.                                #
#                                                                             #
#   History                                                                   #
#    2016-06-07 JFL Created this function                                     #
#                                                                             #
#-----------------------------------------------------------------------------#

$pipeThreadName = "Control Pipe Handler"

Function Start-PipeHandlerThread () {
  Param(
    [Parameter(Mandatory=$true)]
    [String]$pipeName,                  # Named pipe name
    [Parameter(Mandatory=$false)]
    [String]$Event = "ControlMessage"   # Event message
  )
  Start-PSThread -Variables @{  # Copy variables required by function Log() into the thread context
    logDir = $logDir
    logFile = $logFile
    currentUserName = $currentUserName
  } -Functions Now, Log, Receive-PipeMessage -ScriptBlock {
    Param($pipeName, $pipeThreadName)
    try {
      Receive-PipeMessage "$pipeName" # Blocks the thread until the next message is received from the pipe
    } catch {
      Log "(Start-PipeHandlerThread) $pipeThreadName # Error: $_"
      throw $_ # Push the error back to the main thread
    }
  } -Name $pipeThreadName -Event $Event -Arguments $pipeName, $pipeThreadName
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Receive-PipeHandlerThread                                 #
#                                                                             #
#   Description     Get what the pipe handler thread received                 #
#                                                                             #
#   Arguments       See the Param() block                                     #
#                                                                             #
#   Notes                                                                     #
#                                                                             #
#   History                                                                   #
#    2016-06-07 JFL Created this function                                     #
#                                                                             #
#-----------------------------------------------------------------------------#

Function Receive-PipeHandlerThread () {
  Param(
    [Parameter(Mandatory=$true)]
    [PSObject]$pipeThread               # Thread descriptor
  )
  Receive-PSThread -PSThread $pipeThread -AutoRemove
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        $source                                                   #
#                                                                             #
#   Description     C# source of the PSService.exe stub                       #
#                                                                             #
#   Arguments                                                                 #
#                                                                             #
#   Notes           The lines commented with "SET STATUS" and "EVENT LOG" are #
#                   optional. (Or blocks between "// SET STATUS [" and        #
#                   "// SET STATUS ]" comments.)                              #
#                   SET STATUS lines are useful only for services with a long #
#                   startup time.                                             #
#                   EVENT LOG lines are useful for debugging the service.     #
#                                                                             #
#   History                                                                   #
#    2017-10-04 RBL Updated the OnStop() procedure adding the sections        #
#                       try{                                                  #
#                       }catch{                                               #
#                       }finally{                                             #
#                       }                                                     #
#                   This resolved the issue where stopping the service would  #
#                   leave the PowerShell process -Service still running. This #
#                   unclosed process was an orphaned process that would       #
#                   remain until the pid was manually killed or the computer  #
#                   was rebooted                                              #
#                                                                             #
#-----------------------------------------------------------------------------#

#$scriptCopyCname = $scriptCopy -replace "\\", "\\" # Double backslashes. (The first \\ is a regexp with \ escaped; The second is a plain string.)
$scriptCopyCname = $scriptFullName -replace "\\", "\\" # Double backslashes. (The first \\ is a regexp with \ escaped; The second is a plain string.)
$source = @"
  using System;
  using System.ServiceProcess;
  using System.Diagnostics;
  using System.Runtime.InteropServices;                                 // SET STATUS
  using System.ComponentModel;                                          // SET STATUS

  public enum ServiceType : int {                                       // SET STATUS [
    SERVICE_WIN32_OWN_PROCESS = 0x00000010,
    SERVICE_WIN32_SHARE_PROCESS = 0x00000020,
  };                                                                    // SET STATUS ]

  public enum ServiceState : int {                                      // SET STATUS [
    SERVICE_STOPPED = 0x00000001,
    SERVICE_START_PENDING = 0x00000002,
    SERVICE_STOP_PENDING = 0x00000003,
    SERVICE_RUNNING = 0x00000004,
    SERVICE_CONTINUE_PENDING = 0x00000005,
    SERVICE_PAUSE_PENDING = 0x00000006,
    SERVICE_PAUSED = 0x00000007,
  };                                                                    // SET STATUS ]

  [StructLayout(LayoutKind.Sequential)]                                 // SET STATUS [
  public struct ServiceStatus {
    public ServiceType dwServiceType;
    public ServiceState dwCurrentState;
    public int dwControlsAccepted;
    public int dwWin32ExitCode;
    public int dwServiceSpecificExitCode;
    public int dwCheckPoint;
    public int dwWaitHint;
  };                                                                    // SET STATUS ]

  public enum Win32Error : int { // WIN32 errors that we may need to use
    NO_ERROR = 0,
    ERROR_APP_INIT_FAILURE = 575,
    ERROR_FATAL_APP_EXIT = 713,
    ERROR_SERVICE_NOT_ACTIVE = 1062,
    ERROR_EXCEPTION_IN_SERVICE = 1064,
    ERROR_SERVICE_SPECIFIC_ERROR = 1066,
    ERROR_PROCESS_ABORTED = 1067,
  };

  public class Service_$serviceName : ServiceBase { // $serviceName may begin with a digit; The class name must begin with a letter
    private System.Diagnostics.EventLog eventLog;                       // EVENT LOG
    private ServiceStatus serviceStatus;                                // SET STATUS

    public Service_$serviceName() {
      ServiceName = "$serviceName";
      CanStop = true;
      CanPauseAndContinue = false;
      AutoLog = true;

      eventLog = new System.Diagnostics.EventLog();                     // EVENT LOG [
      if (!System.Diagnostics.EventLog.SourceExists(ServiceName)) {         
        System.Diagnostics.EventLog.CreateEventSource(ServiceName, "$logName");
      }
      eventLog.Source = ServiceName;
      eventLog.Log = "$logName";                                        // EVENT LOG ]
      EventLog.WriteEntry(ServiceName, "$exeName $serviceName()");      // EVENT LOG
    }

    [DllImport("advapi32.dll", SetLastError=true)]                      // SET STATUS
    private static extern bool SetServiceStatus(IntPtr handle, ref ServiceStatus serviceStatus);

    protected override void OnStart(string [] args) {
      EventLog.WriteEntry(ServiceName, "$exeName OnStart() // Entry. Starting script '$scriptCopyCname' -SCMStart -ServiceId '$ServiceId'"); // EVENT LOG
      // Set the service state to Start Pending.                        // SET STATUS [
      // Only useful if the startup time is long. Not really necessary here for a 2s startup time.
      serviceStatus.dwServiceType = ServiceType.SERVICE_WIN32_OWN_PROCESS;
      serviceStatus.dwCurrentState = ServiceState.SERVICE_START_PENDING;
      serviceStatus.dwWin32ExitCode = 0;
      serviceStatus.dwWaitHint = 2000; // It takes about 2 seconds to start PowerShell
      SetServiceStatus(ServiceHandle, ref serviceStatus);               // SET STATUS ]
      // Start a child process with another copy of this script
      try {
        Process p = new Process();
        // Redirect the output stream of the child process.
        p.StartInfo.UseShellExecute = false;
        p.StartInfo.RedirectStandardOutput = true;
        p.StartInfo.FileName = "PowerShell.exe";
        p.StartInfo.Arguments = "-ExecutionPolicy Bypass -c & '$scriptCopyCname' -SCMStart -ServiceId '$ServiceId'"; // Works if path has spaces, but not if it contains ' quotes.
        p.Start();
        // Read the output stream first and then wait. (To avoid deadlocks says Microsoft!)
        string output = p.StandardOutput.ReadToEnd();
        // Wait for the completion of the script startup code, that launches the -Service instance
        p.WaitForExit();
        if (p.ExitCode != 0) throw new Win32Exception((int)(Win32Error.ERROR_APP_INIT_FAILURE));
        // Success. Set the service state to Running.                   // SET STATUS
        serviceStatus.dwCurrentState = ServiceState.SERVICE_RUNNING;    // SET STATUS
      } catch (Exception e) {
        EventLog.WriteEntry(ServiceName, "$exeName OnStart() // Failed to start $scriptCopyCname. " + e.Message, EventLogEntryType.Error); // EVENT LOG
        // Change the service state back to Stopped.                    // SET STATUS [
        serviceStatus.dwCurrentState = ServiceState.SERVICE_STOPPED;
        Win32Exception w32ex = e as Win32Exception; // Try getting the WIN32 error code
        if (w32ex == null) { // Not a Win32 exception, but maybe the inner one is...
          w32ex = e.InnerException as Win32Exception;
        }    
        if (w32ex != null) {    // Report the actual WIN32 error
          serviceStatus.dwWin32ExitCode = w32ex.NativeErrorCode;
        } else {                // Make up a reasonable reason
          serviceStatus.dwWin32ExitCode = (int)(Win32Error.ERROR_APP_INIT_FAILURE);
        }                                                               // SET STATUS ]
      } finally {
        serviceStatus.dwWaitHint = 0;                                   // SET STATUS
        SetServiceStatus(ServiceHandle, ref serviceStatus);             // SET STATUS
        EventLog.WriteEntry(ServiceName, "$exeName OnStart() // Exit"); // EVENT LOG
      }
    }

    protected override void OnStop() {
      EventLog.WriteEntry(ServiceName, "$exeName OnStop() // Entry");   // EVENT LOG
      // Start a child process with another copy of ourselves
      try {
        Process p = new Process();
        // Redirect the output stream of the child process.
        p.StartInfo.UseShellExecute = false;
        p.StartInfo.RedirectStandardOutput = true;
        p.StartInfo.FileName = "PowerShell.exe";
        p.StartInfo.Arguments = "-ExecutionPolicy Bypass -c & '$scriptCopyCname' -SCMStop -ServiceId '$ServiceId'"; // Works if path has spaces, but not if it contains ' quotes.
        p.Start();
        // Read the output stream first and then wait. (To avoid deadlocks says Microsoft!)
        string output = p.StandardOutput.ReadToEnd();
        // Wait for the PowerShell script to be fully stopped.
        p.WaitForExit();
        if (p.ExitCode != 0) throw new Win32Exception((int)(Win32Error.ERROR_APP_INIT_FAILURE));
        // Success. Set the service state to Stopped.                   // SET STATUS
        serviceStatus.dwCurrentState = ServiceState.SERVICE_STOPPED;      // SET STATUS
      } catch (Exception e) {
        EventLog.WriteEntry(ServiceName, "$exeName OnStop() // Failed to stop $scriptCopyCname. " + e.Message, EventLogEntryType.Error); // EVENT LOG
        // Change the service state back to Started.                    // SET STATUS [
        serviceStatus.dwCurrentState = ServiceState.SERVICE_RUNNING;
        Win32Exception w32ex = e as Win32Exception; // Try getting the WIN32 error code
        if (w32ex == null) { // Not a Win32 exception, but maybe the inner one is...
          w32ex = e.InnerException as Win32Exception;
        }    
        if (w32ex != null) {    // Report the actual WIN32 error
          serviceStatus.dwWin32ExitCode = w32ex.NativeErrorCode;
        } else {                // Make up a reasonable reason
          serviceStatus.dwWin32ExitCode = (int)(Win32Error.ERROR_APP_INIT_FAILURE);
        }                                                               // SET STATUS ]
      } finally {
        serviceStatus.dwWaitHint = 0;                                   // SET STATUS
        SetServiceStatus(ServiceHandle, ref serviceStatus);             // SET STATUS
        EventLog.WriteEntry(ServiceName, "$exeName OnStop() // Exit"); // EVENT LOG
      }
    }

    public static void Main() {
      System.ServiceProcess.ServiceBase.Run(new Service_$serviceName());
    }
  }
"@

function getPIDJava($def=$null) {
  $spid = $def
  # To looking for powershell process parent of java process
  $processes = @(Get-WmiObject Win32_Process -filter "Name = 'java.exe'" | Where-Object {
    $_.CommandLine -match ".*jospJOD\.jar.*$ServiceId.*"
  })
  foreach ($process in $processes) { # There should be just one, but be prepared for surprises.
    $spid = $process.ProcessId
    $scmdline = $process.CommandLine
    Write-Verbose "$serviceName Process ID = $spid"
  }
  return $spid
}

function getPIDPS($def=$null) {
  $spid = $def
  # To looking for powershell process parent of java process
  $processes = @(Get-WmiObject Win32_Process -filter "Name = 'powershell.exe'" | Where-Object {
    $_.CommandLine -match ".*$scriptCopyCname.*-Service -ServiceId '$ServiceId'.*"
  })
  foreach ($process in $processes) { # There should be just one, but be prepared for surprises.
    $spid = $process.ProcessId
    $scmdline = $process.CommandLine
    Write-Verbose "$serviceName Process ID = $spid"
  }
  return $spid
}

function getPIDExec($def=$null) {
  $spid = $def
  # To looking for powershell process parent of java process
  $processes = @(Get-WmiObject Win32_Process -filter "Name = '$ServiceId.exe'")
  foreach ($process in $processes) { # There should be just one, but be prepared for surprises.
    $spid = $process.ProcessId
    $scmdline = $process.CommandLine
    Write-Verbose "$serviceName Process ID = $spid"
  }
  return $spid
}


#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Main                                                      #
#                                                                             #
#   Description     Execute the specified actions                             #
#                                                                             #
#   Arguments       See the Param() block at the top of this script           #
#                                                                             #
#   Notes                                                                     #
#                                                                             #
#   History                                                                   #
#                                                                             #
#-----------------------------------------------------------------------------#

# Identify the user name. We use that for logging.
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentUserName = $identity.Name # Ex: "NT AUTHORITY\SYSTEM" or "Domain\Administrator"

Log "($scriptName) EXECUTION START"

# The following commands write to the event log, but we need to make sure the PSService source is defined.
New-EventLog -LogName $logName -Source $serviceName -ea SilentlyContinue

# Workaround for PowerShell v2 bug: $PSCmdlet Not yet defined in Param() block
$Status = ($PSCmdlet.ParameterSetName -eq 'Status')

if ($SCMStart) {                # The SCM tells us to start the service
  # Do whatever is necessary to start the service script instance
  Log "(SCMStart) Starting service 2/2 '$serviceName' (via JODService.ps1 -Service -ServiceId '$ServiceId')"
  Write-EventLog -LogName $logName -Source $serviceName -EventId 1001 -EntryType Information -Message "$scriptName -SCMStart: Starting script '$scriptFullName' -Service"
  Start-Process PowerShell.exe -ArgumentList ("-c & '$scriptFullName' -Service -ServiceId '$ServiceId'")
  return
}

if ($Start) {                   # The user tells us to start the service
  Log "(Start) Starting service 1/2 '$serviceName' (via Service Control Manager)"
  Write-EventLog -LogName $logName -Source $serviceName -EventId 1002 -EntryType Information -Message "$scriptName -Start: Starting service $serviceName"
  Start-Service $serviceName # Ask Service Control Manager to start it
  return
}

if ($SCMStop) {         #  The SCM tells us to stop the service
  Log "(SCMStop) Stopping service 2/2 '$serviceName -Service -ServiceId $ServiceId' (via pipe message)"
  # Do whatever is necessary to stop the service script instance
  Write-EventLog -LogName $logName -Source $serviceName -EventId 1003 -EntryType Information -Message "$scriptName -SCMStop: Stopping script $scriptName -Service"
  # Send an exit message to the service instance
  Send-PipeMessage $pipeName "exit"
  return
}

if ($Stop) {                    # The user tells us to stop the service
  Log "(Stop) Stopping service 1/2 '$serviceName' (via Service Control Manager)"
  Write-EventLog -LogName $logName -Source $serviceName -EventId 1004 -EntryType Information -Message "$scriptName -Stop: Stopping service $serviceName"
  try {
    Stop-Service $serviceName -ea 0 # Ask Service Control Manager to stop it
    if (!$?) {
      Log "(Stop) Error stopping service '$serviceName' (via Service Control Manager)"
      exit 2
    }
  } catch {
    Log "(Stop) Exception stopping service '$serviceName' (via Service Control Manager)"
    exit 3
  }
  exit 0
}

if ($Restart) {                 # Restart the service
  Log "(Restart) ServiceId $ServiceId"
  & $scriptFullName -Stop -ServiceId "$ServiceId"
  & $scriptFullName -Start -ServiceId "$ServiceId"
  return
}

if ($GetPID) {                  # Get the current service pid
  Log "(GetPID) ServiceId $ServiceId"
  $spid=$(getPIDJava)
  if ($spid) {
    $spid
  } else {
    Write-Verbose "No PID found"
  }
}

if ($GetPIDScript) {                  # Get the current service pid
  Log "(GetPIDScript) ServiceId $ServiceId"
  $spid=$(getPIDPS)
  if ($spid) {
    $spid
  } else {
    Write-Verbose "No PID found"
  }
}

if ($GetPIDExec) {                  # Get the current service pid
  Log "(GetPIDExec) ServiceId $ServiceId"
  $spid=$(getPIDExec)
  if ($spid) {
    $spid
  } else {
    Write-Verbose "No PID found"
  }
}

if ($GetPIDAll) {                  # Get the current service pid
  Log "(GetPIDAll) ServiceId $ServiceId"
  #ProcessId ParentProcessId CommandLine
  #--------- --------------- -----------
  #     5116            3500 "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -c & 'C:\Users\Roberto\Workspaces\TMPL_DEV\TEMPLATE\build\assemble\1.0-DEVb\build\JOD-Tmpl\0.1\scripts\init\wininitsys\jodService.ps1' -Service -ServiceId 'jodAAAA'
  #     4968            5116 "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" C:\Users\Roberto\Workspaces\TMPL_DEV\TEMPLATE\build\assemble\1.0-DEVb\build\JOD-Tmpl\0.1\scripts\init\wininitsys/../../../start.ps1 -Foreground
  #     9164            4968 "C:\Program Files\Java\jdk-11.0.12\bin\java.exe" -Dlog4j.configurationFile=log4j2.xml -cp jospJOD.jar com.robypomper.josp.jod.JODShell --configs=C:\Users\Roberto\Workspaces\TMPL_DEV\TEMPLATE\build\assemble\1.0-DEVb\build\JOD-Tmpl\0.1/con...

  Write-Host "Service       $ServiceId"
  Write-Host "Java          $(getPIDJava "N/A")"
  Write-Host "PowerShell    $(getPIDPS "N/A")"
  Write-Host "Executable    $(getPIDExec "N/A")"
}

if ($Status) {                  # Get the current service status
  Log "(Status) ServiceId $ServiceId"
  $spid=$(getPIDPS)
  try {
    $pss = Get-Service $serviceName -ea stop # Will error-out if not installed
  } catch {
    "Not Installed"
    return
  }
  $pss.Status
  return
}

if ($Setup) {                   # Install the service
  Log "(Setup) Installing service '$serviceName' (via Service Control Manager)"
  # Check if it's necessary
  try {
    $pss = Get-Service $serviceName -ea stop # Will error-out if not installed
    # Check if this script is newer than the installed copy.
    if ((Get-Item $scriptCopy -ea SilentlyContinue).LastWriteTime -lt (Get-Item $scriptFullName -ea SilentlyContinue).LastWriteTime) {
      Write-Verbose "Service $serviceName is already Installed, but requires upgrade"
      & $scriptFullName -Remove -ServiceId "$ServiceId"
      throw "continue"
    } else {
      Write-Verbose "Service $serviceName is already Installed, and up-to-date"
    }
    exit 0
  } catch {
    # This is the normal case here. Do not throw or write any error!
    Write-Debug "Installation is necessary" # Also avoids a ScriptAnalyzer warning
    # And continue with the installation.
  }
  if (!(Test-Path $installDir)) {											 
    New-Item -ItemType directory -Path $installDir | Out-Null
  }
  # Copy the service script into the installation directory
  if ($ScriptFullName -ne $scriptCopy) {
    Write-Verbose "Installing $scriptCopy"
    Copy-Item $ScriptFullName $scriptCopy
  }
  # Generate the service .EXE from the C# source embedded in this script
  try {
    Write-Verbose "Compiling $exeFullName"
    Add-Type -TypeDefinition $source -Language CSharp -OutputAssembly $exeFullName -OutputType ConsoleApplication -ReferencedAssemblies "System.ServiceProcess" -Debug:$false
  } catch {
    $msg = $_.Exception.Message
    Write-error "Failed to create the $exeFullName service stub. $msg"
    exit 1
  }
  # Register the service
  Write-Verbose "Registering service $serviceName"
  if ($UserName -and !$Credential.UserName) {
    $emptyPassword = New-Object -Type System.Security.SecureString
    switch ($UserName) {
      {"LocalService", "NetworkService" -contains $_} {
        $Credential = New-Object -Type System.Management.Automation.PSCredential ("NT AUTHORITY\$UserName", $emptyPassword)
      }
      {"LocalSystem", ".\LocalSystem", "${env:COMPUTERNAME}\LocalSystem", "NT AUTHORITY\LocalService", "NT AUTHORITY\NetworkService" -contains $_} {
        $Credential = New-Object -Type System.Management.Automation.PSCredential ($UserName, $emptyPassword)
      }
      default {
        if (!$Password) {
          $Credential = Get-Credential -UserName $UserName -Message "Please enter the password for the service user"
        } else {
          $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
          $Credential = New-Object -Type System.Management.Automation.PSCredential ($UserName, $securePassword)
        }
      }
    }
  }
  if ($Credential.UserName) {
    Log "(Setup) $scriptName -Setup -ServiceId '$ServiceId' # Configuring the service to run as $($Credential.UserName)"
    $pss = New-Service $serviceName $exeFullName -DisplayName $serviceDisplayName -Description $ServiceDescription -StartupType Automatic -Credential $Credential
  } else {
    Log "(Setup) $scriptName -Setup -ServiceId '$ServiceId' # Configuring the service to run by default as LocalSystem"
    $pss = New-Service $serviceName $exeFullName -DisplayName $serviceDisplayName -Description $ServiceDescription -StartupType Automatic
  }
  function Set-ServiceRecovery{
      [alias('Set-Recovery')]
      param
      (
          [string] [Parameter(Mandatory=$true)] $ServiceDisplayName,
          [string] $action1 = "restart",
          [int] $time1 =  30000, # in miliseconds
          [string] $action2 = "restart",
          [int] $time2 =  30000, # in miliseconds
          [string] $actionLast = "restart",
          [int] $timeLast = 30000, # in miliseconds
          [int] $resetCounter = 4000 # in seconds
      )
      $services = Get-CimInstance -ClassName 'Win32_Service' -ComputerName $Server| Where-Object {$_.DisplayName -imatch $ServiceDisplayName}
      $action = $action1+"/"+$time1+"/"+$action2+"/"+$time2+"/"+$actionLast+"/"+$timeLast
      foreach ($service in $services){
          # https://technet.microsoft.com/en-us/library/cc742019.aspx
          $output = sc.exe failure $($service.Name) actions= $action reset= $resetCounter
      }
  }
  Set-ServiceRecovery -ServiceDisplayName "$serviceDisplayName"
  return
}

if ($Remove) {                  # Uninstall the service
  Log "(Remove) Uninstalling service '$serviceName' (via Service Control Manager)"
  # Check if it's necessary
  try {
    $pss = Get-Service $serviceName -ea stop # Will error-out if not installed
  } catch {
    Write-Verbose "Already uninstalled"
    return
  }
  Stop-Service $serviceName # Make sure it's stopped
  # In the absence of a Remove-Service applet, use sc.exe instead.
  Write-Verbose "Removing service $serviceName"
  $msg = sc.exe delete $serviceName
  if ($LastExitCode) {
    Write-Error "Failed to remove the service ${serviceName}: $msg"
    exit 1
  } else {
    Write-Verbose $msg
  }
  # Remove the installed files
  if (Test-Path $installDir) {
    foreach ($ext in ("exe", "pdb", "ps1")) {
      $file = "$installDir\$serviceName.$ext"
      if (Test-Path $file) {
        Write-Verbose "Deleting file $file"
        Remove-Item $file
      }
    }
    if (!(@(Get-ChildItem $installDir -ea SilentlyContinue)).Count) {
      Write-Verbose "Removing directory $installDir"
      Remove-Item $installDir
    }
  }
  
  $Date = Get-Date
  $now = ""
  $now += "{0:0000}{1:00}{2:00}_" -f $Date.Year, $Date.Month, $Date.Day
  $now += "{0:00}{1:00}{2:00}" -f $Date.Hour, $Date.Minute, $Date.Second
  Log "(Remove) Move current log to $($logFile)_$now"
  Move-Item -Path "$logFile" -Destination "$($logFile)_$now"
  return
}

if ($Control) {                 # Send a control message to the service
  Send-PipeMessage $pipeName $control
}

if ($Service) {                 # Run the service
  Log "(Service) Run service '$serviceName' (via $PID powershell loop)"
  Write-EventLog -LogName $logName -Source $serviceName -EventId 1005 -EntryType Information -Message "$scriptName -Service # Beginning background job"
  
  $CURRENT_DIR=(Get-Item .).FullName
  try {
    # Start the control pipe handler thread
    $pipeThread = Start-PipeHandlerThread $pipeName -Event "ControlMessage"
    
    # Setup Windows Services Manager listener
    Receive-PSThread

    # Startup JOD Daemon as background process
    $JOD_START_LOGS=$(powershell "$scriptPath/../../../start.ps1")
    Log "(Service) ########################"
    foreach ($l in $JOD_START_LOGS) {
      Log "(Service) $l"
    }
    Log "(Service) ########################"
    $JOD_PID=$(powershell "$scriptPath/../../../scripts/jod/get-jod-pid.ps1 -NO_LOGS")
    Log "(Service) Script 'start.ps1' executed and started JOD with PID='$JOD_PID'"
    $jodIsRunning = ($JOD_PID -ne '')
    
    ###### Example that wakes up and logs a line every 10 sec: ######
    # Start a periodic timer
    $timerName = "Sample service timer"
    $period = 5 # seconds
    $timer = new-object System.Timers.Timer
    $timer.Interval = ($period * 1000) # Milliseconds
    $timer.AutoReset = $true # Make it fire repeatedly
    Register-ObjectEvent $timer -EventName Elapsed -SourceIdentifier $timerName -MessageData "TimerTick"
    $timer.start() # Must be stopped in the finally block
    
    # Now enter the main service event loop
    Log "(Service) Start powershell loop for service '$serviceName'"
    do { # Keep running until told to exit by the -Stop handler
      $event = Wait-Event # Wait for the next incoming event
      $source = $event.SourceIdentifier
      $message = $event.MessageData
      $eventTime = $event.TimeGenerated.TimeofDay
      Write-Debug "Event at $eventTime from ${source}: $message"
      #Log "(Service) Event at $eventTime from ${source}: $message"
      $event | Remove-Event # Flush the event from the queue
      switch ($message) {
        "ControlMessage" { # Required. Message received by the control pipe thread
          $state = $event.SourceEventArgs.InvocationStateInfo.state
          Write-Debug "$script -Service # Thread $source state changed to $state"
          switch ($state) {
            "Completed" {
              $message = Receive-PipeHandlerThread $pipeThread
              Log "(Service) Received control message: $Message"
              if ($message -ne "exit") { # Start another thread waiting for control messages
                $pipeThread = Start-PipeHandlerThread $pipeName -Event "ControlMessage"
              }
            }
            "Failed" {
              $error = Receive-PipeHandlerThread $pipeThread
              Log "(Service) $source thread failed: $error"
              Start-Sleep 1 # Avoid getting too many errors
              $pipeThread = Start-PipeHandlerThread $pipeName -Event "ControlMessage" # Retry
            }
          }
        }
        "TimerTick" { # Example. Periodic event generated for this example
          #Log "(Service) Timer ticked"
          $java=getPIDJava
          $script=getPIDPS
          $exec=getPIDExec
          Log "(Service) Test $($ServiceId): $java; $script; $exec"
          if ($null -eq $java) {
            Log "(Service) Java not running, shutdown service $scriptName"
            $jodIsRunning = $false
            Send-PipeMessage $pipeName "exit"
          }
        }
        default { # Should not happen
          Log "(Service) Unexpected event from ${source}: $Message"
        }
      }
    } while ($message -ne "exit")
  } catch { # An exception occurred while runnning the service
    $msg = $_.Exception.Message
    $line = $_.InvocationInfo.ScriptLineNumber
    Log "(Service) Exception at line ${line} in powershell loop for service '$serviceName': $msg"

  } finally { # Invoked in all cases: Exception or normally by -Stop
    Log "(Service) End of powershell loop for service '$serviceName'"
    
    
    # Cleanup the periodic timer used in the above example
    Unregister-Event -SourceIdentifier $timerName
    $timer.stop()

    # Terminate the control pipe handler thread
    Get-PSThread | Remove-PSThread # Remove all remaining threads
    # Flush all leftover events (There may be some that arrived after we exited the while event loop, but before we unregistered the events)
    $events = Get-Event | Remove-Event
    # Log a termination event, no matter what the cause is.
    Write-EventLog -LogName $logName -Source $serviceName -EventId 1006 -EntryType Information -Message "$script -Service # Exiting"
  
    # Shutdown JOD Daemon as background process
    $java=getPIDJava
    if ($null -ne $java) {
      Log "(Service) Shutdown JOD Daemon with PID='$java'"
      $JOD_STOP_LOGS=$(powershell "$scriptPath/../../../stop.ps1")
      Log "(Service) ########################"
      foreach ($l in $JOD_STOP_LOGS) {
        Log "(Service) $l"
      }
      Log "(Service) ########################"
    } else {
      Log "(Service) JOD Daemon already halted"
    }

    # Shutdown JOD Service to inform SCM that the JOD Daemon crashed
    if (!$jodIsRunning) {
      $exec=getPIDExec
      Log "(Service) Shutdown JOD Service with PID='$exec'"
      stop-process -id $exec
    }

    Log "(Service) Terminated"
  }
  return
}
