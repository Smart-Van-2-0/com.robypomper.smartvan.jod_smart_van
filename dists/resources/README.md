# JOD Smart Van - 1.0.0-DEV

Documentation for JOD Smart Van. This JOD Distribution allow to start up and
manage a JOD Agent that represent
a [Smart Van Box](https://smartvan.johnosproject.org).

## JOD Distribution Specs

<table>
  <tr><th>Current version</th><td>1.0.0-DEV</td></tr>
  <tr><th>References</th><td><a href="http://smartvan.johnosproject.org/docs/software/jod_smart_van/jod_smart_van">JOD Smart Van @ Smart Van Project</a></td></tr>
  <tr><th>Repository</th><td><a href="https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van/">com.robypomper.smartvan.jod_smart_van @ GitHub</a></td></tr>
  <tr><th>Downloads 1</th><td><a href="http://smartvan.johnosproject.org/docs/software/jod_smart_van/downloads">JOD Smart Van Downloads @ Smart Van Project</a></td></tr>
  <tr><th>Downloads 2</th><td><a href="https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van/releases">com.robypomper.smartvan.jod_smart_van/releases > Releases @ GitHub</a></td></tr>
</table>

This is the JOD Distribution for
the [Smart van project](https://smartvan.johnosproject.org).
It abstracts all devices and resources that can be found in a camper/caravan or
van like lights, fan, fridges but also power energy, waters and many more.

**NB!:** This distribution requires some features available only on the 2.2.4
version of the JOD Distribution. Actually there is at least the 2.2.3 JOD
version as public available. So, in order to build this distribution, you'll
need to download the JOD source code and publish it locally (with the 2.2.4-DEV
version). Then the JOD Smart Van distribution's build script will be able to
include the 2.2.4-DEV JOD version from your local repository.

As a first version, this distribution contains only the support to some of the
Smart Van Specifications because it's still missing some firmware.<br/>
Actually, the JOD Smart Van includes following firmwares:
* [FW Victron](https://smartvan.johnosproject.org/docs/software/firmware/fw_victron): v 1.0.2 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.victron/)
* [FW SIM 7600](https://smartvan.johnosproject.org/docs/software/firmware/fw_sim7600): v 1.0.0 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.sim7600/)
* [FW UPS Pack_V3](https://smartvan.johnosproject.org/docs/software/firmware/fw_upspack_v3): v 1.0.0 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.upspack_v3/)
* [FW Sense Hat](https://smartvan.johnosproject.org/docs/software/firmware/fw_sensehat): v 1.0.0 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.sensehat/)
* [FW IO Exp](https://smartvan.johnosproject.org/docs/software/firmware/fw_ioexp): v 1.0.0 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.ioexp/)

## JOD Distribution Usage

To run JOD Smart Van, you need to have the JOD Smart Van distribution available.
You can download it in compressed format from
the [official repository](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van/releases)
or generate it using the `build.sh` script from
the [JOD Smart Van](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van) repository.
Then you can copy the resulting files into a remote machine or execute it locally.

:::note
To run the JOD Smart Van on your development machine, or on any other machine
without the right peripherals, you can set the `SIMULATE` variable to "true"
into the `/configs/jod_dist_configs.sh` file. This will enable the firmware
simulation mode for all firmwares that supports it.
:::

More details on JOD Smart Van distribution usage are available at
the [Usage](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van/docs/usage.md)
page.

### Build and run locally

1. **Build JOD Smart Van Distribution:**
  After cloning the JOD Smart Van repository, you can build the distribution
  using the `build.sh` script. 
  Depending on the DIST_ARTIFACT and DIST_VER variables set into the
  `/configs/jod_dist_configs.sh` file, the distribution folder will
  be `build/{DIST_ARTIFACT}/{VER}`.
    ```shell
    $ cd com.robypomper.smartvan.jod_smart_van
    $ bash build.sh configs/jod_dist_configs-DEV.sh
    $ cd build/JOD_Smart_Van/0.1.0
    ``` 
  More details on JOD Smart Van distribution build are available at
  the [Development](/https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_vandocs/development.md)
  page.
2. **Run the JOD Smart Van in foreground:**
  You can run the JOD Smart Van in foreground mode using the `start.sh` script.
  This script will start the JOD Smart Van agent in foreground mode, so you can
  interact with it using 
  the [JOD Shell](https://docs.johnosproject.org/references/josp/jod/specs/shell)
  and his commands.
  ```shell
  $ bash start.sh true
  >> Type 'quit' to shutdown the JOD Smart Van agent when execte in foreground mode
  ```

### Download and run remotely

1. **Download and extract JOD Smart Van Distribution:**
  You can copy the link of the JOD Smart Van distribution from
  the [official repository](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van/releases)
  then you can download it directly on your remote machine using the `wget`
  command. After that, you can extract the distribution using the `tar` command.
    ```shell
    $ wget https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van/archive/refs/tags/0.1.0.tar.gz
    $ tar -xzf 0.1.0.tar.gz -c JOD_Smart_Van
    $ cd JOD_Smart_Van/0.1.0
    ```
2. **Run the JOD Smart Van in background:**
  You can run the JOD Smart Van using the `start.sh` script.
  By default, this script will start the JOD Smart Van agent in background mode,
  You can find the running instance logging file into the `logs` folder.
  ```shell
  $ bash start.sh
  ```
  :::note
  To halt the JOD Smart Van instance, you can use the `stop.sh` script. That
  script will kill the running instance if it's running.
   :::

## JOD Distribution Configs

To alter the JOD Distribution behavior, you can edit
the [`jod_configs.sh`](/configs/jod_configs.sh) into the `/configs`
folder. This file contains the following variables:

| Variable      | Default                    | Description                                                                  |
|---------------|----------------------------|------------------------------------------------------------------------------|
| `SIMULATE`    | `false`                    | Enable the firmware simulation option for all firmwares that supports it     |
| `VENV`        | `false`                    | If true, execute all python firmware in their own virtual environment        |
| `INLINE_LOGS` | `false`                    | If true, then it print all logging messages from firmwares                   |
| `JOD_YML`     | `$JOD_DIR/configs/jod.yml` | Absolute or $JOD_DIR relative file path for JOD config file                  |
| `JAVA_HOME`   | `null`                     | Absolute path to Java home folder (ex: /usr/lib/jvm/java-11-openjdk-amd64/)  |

**Simulate firmware:**

If `SIMULATE` is set to `true`, then all firmwares that supports the simulation
option will be executed in simulation mode. This means that the firmware will
not try to connect to the real device but it will simulate the device behavior
using a random value generator.

**Virtual environment:**

If `VENV` is set to `true`, then all python firmwares will be executed in their
own virtual environment. This means that the firmware will be executed in a
separate python environment with its own dependencies. This is useful to avoid
dependencies conflicts between firmwares.

To be able to use this feature, the `python3-venv` package must be installed on
the system. Then, for each firmware, generate his own venv folder using the
`python3 -m venv <firmware_folder>/venv` command. It requires to be executed
only once for each firmware and an internet connection is required.

**Inline logs:**

If `INLINE_LOGS` is set to `true`, then all logging messages from firmwares will
be printed on the console when the JOD Smart Van is executed in foreground mode.
This is useful to debug the firmware behavior.

Otherwise, you can find a log file for each firmware into the `logs` folder.

## Collaborate

This project is part of the [Smart Van Project](https://smartvan.johnosproject.org),
and it's published under an Open Source licence to allow the community to
contribute to the project.

If you want to contribute to the project, you can start by reading the
[Contribution Guidelines](https://smartvan.johnosproject.org/collaborate) page.
Otherwise, you can clone current repository and start to customize your own
JOD Smart Van distribution. Check out the project's structure and 'how to work on
it', on
the [Development](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van/docs/development.md)
page.
