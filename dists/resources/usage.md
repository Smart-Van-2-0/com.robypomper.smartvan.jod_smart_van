# JOD Smart Van - Usage

## System requirements

To run the JOD Smart Van distribution successfully, it's essential to have the
following software installed: Java and Python.

* Java 8 or higher: for JOD execution
* python3: for firmware execution
* python3-venv: for venv option on firmware execution

Additionally, depending on the enabled firmwares, it may be necessary to fulfill
their requirements. Here is the list of firmwares included in the JOD Smart Van
distribution:

* [FW Victron](https://smartvan.johnosproject.org/docs/software/firmware/fw_victron): v 1.0.2 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.victron/)
* [FW SIM 7600](https://smartvan.johnosproject.org/docs/software/firmware/fw_sim7600): v 1.0.0 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.sim7600/)
* [FW UPS Pack_V3](https://smartvan.johnosproject.org/docs/software/firmware/fw_upspack_v3): v 1.0.0 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.upspack_v3/)
* [FW Sense Hat](https://smartvan.johnosproject.org/docs/software/firmware/fw_sensehat): v 1.0.0 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.sensehat/)
* [FW IO Exp](https://smartvan.johnosproject.org/docs/software/firmware/fw_ioexp): v 1.0.0 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.ioexp/)

:::warning
Both the JOD Smart Van distribution and the firmwares are developed and tested
using linux. Therefore, it is recommended to use a linux system to run the JOD
Smart Van distribution.
:::

## Download and run

The most common method to run JOD Smart Van distribution is on an embedded
device, such as a Raspberry Pi. The procedure is similar to many other software
installations: download, extract, and run.

1. **Download:**
  Download the latest available version of JOD Smart Van in compressed format.
  For a list of versions and respective links, visit
  the [Downloads](https://smartvan.johnosproject.org/docs/software/jod_smart_van/downloads)
  page or directly the [Release@GitHub](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van/releases)
  for download links.
    ```shell
    $ wget https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van/archive/refs/tags/0.1.0.tar.gz
    ```
2. **Extract:**
  Extract the downloaded file and navigate into the created folder.
    ```shell
    $ tar -xzf 0.1.0.tar.gz -c JOD_Smart_Van
    $ cd JOD_Smart_Van/0.1.0
    ```
3. **Run:**
  Start JOD Smart Van; along with the JOD daemon, the enabled firmwares will
  also be launched. You can interact with the JOD Smart Van instance using the
  [JOD Shell](https://docs.johnosproject.org/references/josp/jod/specs/shell)
  commands.
     ```shell
      $ bash start.sh true
         >> type 'exit` to stop the JOD Smart Van instance
      ```
  You can also run JOD Smart Van in background mode and the stop it, using the
  following commands:
     ```shell
      $ bash start.sh
      $ bash stop.sh
      ```

Once satisfied, you can install JOD Smart Van as a service and ensure it runs
on every system boot. Otherwise, check
the [Run on development machine](development.md#run-on-development-machine)
section to start an instance of JOD Smart Van that simulate the underlying
hardware.

## Install as service/daemon

After downloading the desired version of the JOD Smart Van distribution, you can
install it as a system service/daemon.

This ensures that JOD Smart Van starts with every system boot, and, upon
shutdown, the halt signal is sent, stopping also all enabled firmwares.

1. **Download:**
  Download the latest available version of JOD Smart Van in compressed format.
  For a list of versions and respective links, visit
  the [Downloads](https://smartvan.johnosproject.org/docs/software/jod_smart_van/downloads)
  page or directly the [Release@GitHub](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van/releases)
  for download links.
    ```shell
    $ wget https://github.com/Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van/archive/refs/tags/0.1.0.tar.gz
    ```
2. **Extract:**
  Extract the downloaded file and navigate into the created folder.
    ```shell
    $ tar -xzf 0.1.0.tar.gz -c JOD_Smart_Van
    $ cd JOD_Smart_Van/0.1.0
    ```
3. **Install:**
  Install the JOD Smart Van as service/daemon
   ```shell
   $ bash install.sh
   ```
4. **Check status:**
 Check the status of the JOD Smart Van service/daemon.
   ```shell
   $ bash state.sh
   ```
5. **Uninstall:**
  Uninstall the JOD Smart Van service/daemon.
    ```shell
    $ bash uninstall.sh
    ```

Installation and init system configurations are inherited from the JOD Dist TMPL,
and currently it supports following init systems:
* launchd (macOS)
* systemd (Linux)
* wininitsys (Windows)

## JOD Distribution Configs

To alter the JOD Distribution behavior, you can edit
the [`jod_configs.sh`](/dists/configs/jod_configs.sh) into the `/dists/configs`
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
not try to connect to the real device, but it will simulate the device behavior
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

## Other scripts

Among the `start.sh` script, there are other scripts that can be used to manage
the JOD Smart Van instance:

| Command                                  | Description                                                                                                   |
|------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| Start    <br/>```$ bash start.sh```      | Start local JOD instance in background mode, logs can be retrieved via ```tail -f logs/console.log``` command |
| Start    <br/>```$ bash start.sh true``` | Start local JOD instance in foreground mode, user can interact with the instance using the JOD Shell          |
| Stop     <br/>```$ bash stop.sh```       | Stop local JOD instance, if it's running                                                                      |
| State    <br/>```$ bash state.sh```      | Print the local JOD instance state (obj's id and name, isRunning, PID...)                                     |
| Install  <br/>```$ bash install.sh```    | Install local JOD instance as system daemon/service                                                           |
| Uninstall<br/>```$ bash uninstall.sh```  | Uninstall local JOD instance as system daemon/service                                                         |

## Alternative JOD structures

**In the JOD Smart Van distribution, edit the `jod.structure.path` from the
`configs/jod.yml`** file with desired JOD structure file path. The default value
is `configs/struct.jod`, but you can use one of the following alternative
structures:

* `struct_fw_XY.jod`: JOD SV structure but only FW XY's related pillars
* `struct_fw_XY_all.jod`: a JOD structure containing all FW XY's provided properties as pillars
* `struct_specs_NAME.jod`: a JOD structure containing only pillars for the specifications with NAME sub-group 

## Logging and troubleshooting

When the JOD Smart Van distribution is running, it saves its log files within
the `logs` folder, just as all firmwares are configured to use the same
directory. These files are generated regardless of whether JOD is running in the
foreground or background.
