# JOD Smart Van - Change Log

[README](README.md) | [CHANGELOG](CHANGELOG.md) | [TODOs](TODOs.md) | [LICENCE](LICENCE.md)

## 1.0.1

* Updated FW versions to:
  * FW Victron: v 1.0.3
  * FW SIM 7600: v 1.0.1
  * FW UPS Pack_V3: v 1.0.1
  * FW Sense Hat: v 1.0.1
  * FW IO Exp: v 1.0.1
* Enabled venv for firmwares by default
* Added scripts to manage firmwares' venvs
* Updated pre-startup.sh script to support new serial names for RPi OS (Bookworm)
* Updated struct.jod according to updated firmwares
* Updated struct.jod according to the SmartVanBox hardware specs and created an example struct_GENERIC.jod file
* Replaced SV Project url from 'smartvan.johnosproject.org' to 'www.smartvanbox.org'
* Removed the `--debug` option in the FWs execution
* Added support to GralVM (used in JOD 2.2.5)
* Fixed log file name in log4j2_TMPL_224.xml
* Fixed DBus session startup, added a start.sh customized script that starts a DBus session before startup all firmwares
* Fixed wrong command for UPS firmware startup from pre-startup.sh script
* Fixed compressed files generation in publish.sh

## 1.0.0

* Updated [JOD](https://docs.johnosproject.org/references/josp/jod/) agent to v 2.2.4
* Setup production and development build configs
* Updated the firmware mngm into `pre-startup.sh` and `post-startup.sh` scripts
* Updated the [FW Victron](https://www.smartvanbox.org/docs/software/firmware/fw_victron) to v 1.0.2 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.victron/)
* Included the [FW SIM 7600](https://www.smartvanbox.org/docs/software/firmware/fw_sim7600) v 1.0.0 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.sim7600/)
* Included the [FW UPS Pack_V3](https://www.smartvanbox.org/docs/software/firmware/fw_upspack_v3) v 1.0.0 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.upspack_v3/)
* Included the [FW Sense Hat](https://www.smartvanbox.org/docs/software/firmware/fw_sensehat) v 1.0.0 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.sensehat/)
* Included the [FW IO Exp](https://www.smartvanbox.org/docs/software/firmware/fw_ioexp) v 1.0.0 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.ioexp/)
* Updated the `struct.jod` file to the SV Specs
* Added structure files for any SV specs sub-group
* Added structure files for any firmware included

## 0.1.0

* Initialized from JODDistTMPL `1.0.3`, then updated to `1.0.4-DEV`
* Configured distribution for JOD Smart Van `0.1.0`
* Included the [FW Victron](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw_victron/) as dependency from local dir
* Updated the struct.jod with pillars for any info provided by the FW Victron
* Added the `pre-startup.sh` and `post-startup.sh` scripts with FW Victron mngm
* Added the SolarCharger pillars (flat) to the `struct.jod` file
* Added README.md, CHANGELOG.md
