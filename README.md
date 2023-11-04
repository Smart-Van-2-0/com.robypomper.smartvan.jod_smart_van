# JOD Smart Van Distribution

This is the main repository for the **JOD Smart Van distribution** as part of
the [Smart Van Project](https://smartvan.johnosproject.org/).<br />
It's based on the [JODDistTMPL](https://github.com/johnosproject/com.robypomper.jodp.jod.template),
so this repo follows his conventions.

**Dist Name:** JOD Smart Van<br />
**Dist Artifact:** JOD_Smart_Van<br />
**Dist Version:** 1.0.0-DEV

[README](README.md) | [CHANGELOG](CHANGELOG.md) | [TODOs](TODOs.md) | [LICENCE](LICENCE.md)

This distribution represent a Smart Van object as defined from the [Smart Van Project](https://smartvan.johnosproject.org/)
website.

Actually, the first version contains only the support to the solar charger
(e.g. the Victron SmartSolar or BlueSolar via Serial2USB). Checkout the
[FW Victron](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.victron/)
repository for more info on supported devices and data provided.


## Build and run

This repo contains a JOD Dist TMPL distribution, so before run it you must build it.
Following the JOD Dist TMPL documentation, to build a distribution you must run the
`build.sh` script from the main repository dir.

```shell
$ bash scripts/build.sh
$ DEBUG=true bash scripts/build.sh      // to enable debug logs
```

Afther the build terminates, your JOD Smart Van distribution is ready into the
`build/JOD_Smart_Van/{VERSION}` dir.

Now, you can run or install the built JOD Smart Van distribution. As described
into the distribution README.md (at `build/JOD_Smart_Vane/{VERSION}`) you can
manage the distribution using the following scripts:

| Command | Description |
|---------|-------------|
| Start    <br/>```$ bash start.sh```     | Start local JOD instance in background mode, logs can be retrieved via ```tail -f logs/console.log``` command |
| Start    <br/>```$ bash start.sh true```| Start local JOD instance in foreground mode, user can interact with the instance using the JOD Shell |
| Stop     <br/>```$ bash stop.sh```      | Stop local JOD instance, if it's running |
| State    <br/>```$ bash state.sh```     | Print the local JOD instance state (obj's id and name, isRunning, PID...) |
| Install  <br/>```$ bash install.sh```   | Install local JOD instance as system daemon/service |
| Uninstall<br/>```$ bash uninstall.sh``` | Uninstall local JOD instance as system daemon/service |


## Develop

On any dev-cycle this repo increase the minor version and adds a new firmware.
As for the first version (the `0.1.0`) added the support to the FW Victron.

Versions, object's structure and development roadmap are defined on the
[Smart Van Project](https://smartvan.johnosproject.org/) website.
