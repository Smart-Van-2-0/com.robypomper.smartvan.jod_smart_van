# JOD Smart Van - 1.0.0-DEV

Documentation for JOD Smart Van. This JOD Distribution allow to start up and
manage a JOD Agent that represent a [Smart Van Box](https://smartvan.johnosproject.org).


## JOD Distribution Specs

Author info

<table>
  <tr><th>Current version</th><td>1.0.0-DEV</td></tr>
  <tr><th>References</th><td><a href="{REFERENCES_URL}">{REFERENCE_NAME} @ JOSP Docs</a></td></tr>
  <tr><th>Repository</th><td><a href="https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van/">{REPO_NAME} @ GitHub</a></td></tr>
  <tr><th>Downloads</th><td><a href="https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van/releases">{REPO_NAME} > Downloads @ Bitbucket</a></td></tr>
</table>

This is the JOD Distribution for the [Smart van project](https://smartvan.johnosproject.org).
It abstracts all devices and resources that can be found in a camper/caravan or
van like lights, fan, fridges but also power energy, waters and many more.

**NB!:** This distribution requires some features available only on the 2.2.4
version of the JOD Distribution. Actually there is at least the 2.2.3 JOD
version as public available. So, in order to build this distribution, you'll
need to download the JOD source code and publish it locally (with the 2.2.4-DEV
version). Then the JOD Smart Van distribution's build script will be able to
include the 2.2.4-DEV JOD version from your local repository.

Current version (0.1.0) supports only [Victron](https://www.victronenergy.com/)
devices (SmartSolar or BlueSolar) via serial communication (aka VE.Direct).
More info on the [FW Victron](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.victron/)
repository.

Actually this distribution don't provide any configuration.


## JOD Distribution Usage

### Locally JOD Instance

Each JOD Distribution comes with a set of script for local JOD Instance management.

| Command | Description |
|---------|-------------|
| Start    <br/>```$ bash start.sh```     | Start local JOD instance in background mode, logs can be retrieved via ```tail -f logs/console.log``` command |
| Start    <br/>```$ bash start.sh true```| Start local JOD instance in foreground mode, user can interact with the instance using the JOD Shell |
| Stop     <br/>```$ bash stop.sh```      | Stop local JOD instance, if it's running |
| State    <br/>```$ bash state.sh```     | Print the local JOD instance state (obj's id and name, isRunning, PID...) |
| Install  <br/>```$ bash install.sh```   | Install local JOD instance as system daemon/service |
| Uninstall<br/>```$ bash uninstall.sh``` | Uninstall local JOD instance as system daemon/service |

### Remote JOD Instance

To deploy and manage a JOD instance on remote device (local computer, cloud server,
object device...) please use the [John Object Remote](https://www.johnosproject.org/docs/references/tools/john_object_remote/)
tools.