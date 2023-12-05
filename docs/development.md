# JOD Smart Van - Development

## Project structure

The JOD Smart Van project is a JOD distribution. It is based on the
[JOD Dist TMPL](https://docs.johnosproject.org/references/tools/jod_dist_template/)
project and inherits its structure. The JOD Smart Van project is organized with
the following directory and files:

* `configs/jod_dist_configs[-DEV].(sh|ps1)`:<br/>
  Main distribution configuration file. It contains all the variables used by
  the JOD Dist TMPL scripts to build the distribution. It also contains the
  firmware list to include into the distribution.
* `dists/configs/jod_configs[-DEV].(sh|ps1)`:<br/>
  JOD execution's configuration file. It contains all the shell's variables set
  before executing any JOD's script (like start.sh etc...).
* `dists/configs/struct.jod`:<br/>
  JOD structure file. It contains the JOD Smart Van structure, i.e., the
  endpoints exposed by the JOD Smart Van agent (aka John's Pillars/Smart Van
  Specifications).
* `dists/configs/jod_TMPL.yml`:<br/>
  JOD configuration file. It contains all the variables used by the JOD daemon
  to run the JOD Smart Van agent.
* `dists/configs/log4j2_TMPL*.xml`:<br/>
  Log4j2 configuration file. It contains the configuration for the JOD Smart Van
  agent's logger. Depending on the JOD version's used, there are two different
  files: one for JOD 2.2.3 and one for JOD 2.2.4.
* `dists/resources/README.md` & Co:<br/>
  Distribution's README.md file and other documentation.
* `dists/resources/configs/struct_*.jod`:<br/>
  Alternative JOD structure files. They are used to test the JOD Smart Van
  distribution with different JOD structures. They can be used also as examples
  to Pillars customization.
* `dists/resources/scripts/pre-startup.sh`:<br/>
  Scripts executed before the JOD Smart Van agent startup. This script  starts
  the firmwares and the JOD Smart Van agent.
* `dists/resources/scripts/post-shutdown.sh`:<br/>
  Scripts executed after the JOD Smart Van agent shutdown. This script stops the
  firmwares.
* `dists/scripts`:    FROM JOD Dist TMPL<br/>
  *Scripts and utils from the JOD Dist TMPL project.* Those scripts are copied
  into the distribution and used to run, stop and install the JOD Smart Van
  distribution.
* `docs`:<br/>
  JOD Smart Van project documentation files.
* `scripts`:    FROM JOD Dist TMPL<br/>
  *Scripts and utils from the JOD Dist TMPL project.* Those scripts are used to
  build, install and publish the JOD Smart Van distribution.

## Build JOD Smart Van distribution

Starting from the JOD Smart Van project, you can generate a JOD Smart Van
distribution using the `scripts/build.sh` command. This command handles the
download of the JOD daemon, all its dependencies, and the configured firmwares.
Afterward, it combines all files (downloaded, configuration, and scripts) into
the folder that constitutes the JOD distribution.

This workflow is made possible by
the [JOD Dist TMPL project](https://docs.johnosproject.org/references/tools/jod_dist_template/),
the foundation of this very project.

```bash
# Standard command
bash scripts/build.sh

# Build development version
bash scripts/build.sh configs/jod_dist_configs-DEV.sh

# Build with debug logs
DEBUG=true bash scripts/build.sh
```

There are two configurations for building a JOD Smart Van distribution:

* Production: `configs/jod_dist_configs.sh|ps1`
* Development: `configs/jod_dist_configs-DEV.sh|ps1`

The two configurations differ not only in their settings but also in where they
retrieve the firmwares. In the case of a production build, the firmwares are
downloaded from their git repositories as compressed files. In the case of a
development build, the firmwares are searched locally, in the same folder as
the JOD Smart Van project.

It is recommended to use the production distribution when deploying it on a
[Smart Van Box](https://smartvan.johnosproject.org/docs/hardware) (aka
Raspberry Pi). If you want to test the distribution or simulate a Smart Van Box,
then the development build is recommended.

Once you have the folder containing the distribution, you
can [run it locally](#run-on-development-machine)
or [deploy it](#deploy-on-remote-machine) on an embedded device (aka Raspberry
Pi).

**NB!:** This distribution requires some features available only on the 2.2.4
version of the JOD Distribution. Actually there is at least the 2.2.3 JOD
version as public available. So, in order to build this distribution, you'll
need to download the JOD source code and publish it locally (with the 2.2.4-DEV
version). Then the JOD Smart Van distribution's build script will be able to
include the 2.2.4-DEV JOD version from your local repository.

## Deploy on remote machine

Once the JOD Smart Van distribution is built, you can copy it to an embedded
device (aka Raspberry Pi) and start it.

To do this, you need an SSH connection to the embedded device. This will be used
to copy the distribution files and to start the distribution itself.

1. Connect and create dir into remote machine (only once)
  ```shell
  $ ssh pi@raspberrypi.local
  (rpi)$ mkdir -p dev/jod_smart_van
  (rpi)$ exit
  ```
2. Copy local sources to remote machine (to upload every updates on distribution)
  ```shell
  $ rsync -av --exclude venv --exclude logs --exclude __pycache__ --exclude .git --exclude 'build*' -e ssh * pi@raspberrypi.local:/home/pi/dev/jod_smart_van
  ```
3. Connect to remote machine and cd to JOD Smart Van distribution dir
  ```shell
  $ ssh pi@raspberrypi.local
  (rpi)$ cd dev/jod_smart_van
  ```
4. Install requirements (only once)
  ```shell
  (rpi)$ sudo apt update
  (rpi)$ sudo apt install default-jdk
  (rpi)$ sudo apt-get install python3 libcairo2-dev libgirepository1.0-dev dbus-x11
  ```
5. Install firmware's requirements (only once)
  ```shell
  (rpi)$ cd dev/jod_smart_van/{FW_DIR}
  (rpi)$ python -m venv venv           # Optional: only for venv support
  (rpi)$ source venv/bin/activate      # Optional: only for venv support
  (rpi-venv)$ pip install -r requirements.txt
  ```
6. Init DBus session (only if required)
  ```shell
  (rpi)$ env | grep DBUS_SESSION_BUS_ADDRESS
  # no response means the DBus session is required
  (rpi)$ exec dbus-run-session -- bash
  (rpi)$ env | grep DBUS_SESSION_BUS_ADDRESS
  # copy the printed output as DBUS Session
  ```
7. Startup the JOD Smart Van distribution
  ```shell
  (rpi)$ bash start.sh
  ```
8. Check the JOD Smart Van distribution status or print logs
  ```shell
  (rpi)$ bash status.sh
  (rpi)$ tail -f logs/jospJOD.log
  (rpi)$ tail -f logs/fw_{code}_{timestamp}.log
  ```
9. Shutdown the JOD Smart Van distribution
  ```shell
  (rpi)$ bash stop.sh
  ```

NB: If the remote machine does not have any graphical server installed, the DBUS
daemon is likely not running, and thus, it needs to be started manually.

### Configure SSH keys to avoid password usage

Procedure to configure SSH keys to avoid password usage when connecting to a
remote machine. The examples below are for a Raspberry Pi, but the procedure is
the same for any other machine, remembering to replace the username and hostname
with the correct ones.

1. Create a 'public_keys' on the remote machine
  ```shell
  $ ssh pi@raspberrypi.local
  (rpi)$ mkdir -p .ssh/public_keys
  (rpi)$ exit
  ```
2. Generate a new key pair and copy the public one on the remote machine
  ```shell
  $ ssh-keygen -t rsa
  #  save it in /home/USER/.ssh/id_rsa_for_rpi
  $ scp /home/USER/.ssh/id_rsa_for_rpi.pub pi@raspberrypi.local:/home/pi/.ssh/public_keys
  ```
3. Set up the new public key into remote machine
  ```shell
  $ ssh pi@raspberrypi.local
  (rpi)$ cat .ssh/pub_keys/id_rsa_for_rpi.pub >> .ssh/authorized_keys
  ```

Those steps are required only once.
...

## Run on development machine

When building the JOD Smart Van distribution using the development
configurations `jod_dist_configs-DEV.sh`, a distribution ready for execution on
the development machine is generated. For example, options like `SIMULATE` and
`VENV` are enabled, allowing the simulation of underlying hardware and testing
the distribution without physically connecting all sensors and actuators.

1. **Clone repositories:**
   Clone the JOD Smart Van project repository and those of its related firmwares
   within the same folder. For a complete list of available firmwares, visit the
   [Smart Van 2.0 Firmware](https://github.com/search?q=topic%3Afirmware+org%3ASmart-Van-2-0&type=Repositories)
   page.

  ```shell
  mkdir jod_sv_dev
  cd jod_sv_dev
  git clone git@github.com:Smart-Van-2-0/com.robypomper.smartvan.jod_smart_van.git
  git clone git@github.com:Smart-Van-2-0/com.robypomper.smartvan.fw.victron.git
  git clone git@github.com:Smart-Van-2-0/com.robypomper.smartvan.fw.sim7600.git
  git clone git@github.com:Smart-Van-2-0/com.robypomper.smartvan.fw.upspack_v3.git
  git clone git@github.com:Smart-Van-2-0/com.robypomper.smartvan.fw.sensehat.git
  git clone git@github.com:Smart-Van-2-0/com.robypomper.smartvan.fw.ioexp.git
  ```

2. **Build JOD Smart Van distribution:**
   Generate the JOD Smart Van distribution using the development configurations.
   This will copy the firmwares from local folders. For more information, refer
   to the Build JOD Smart Van distribution section.

  ```shell
  cd com.robypomper.smartvan.jod_smart_van.git
  bash scripts/build.sh configs/jod_dist_configs-DEV.sh
  ```

3. **Run on the local machine:**
   Start JOD Smart Van; along with the JOD daemon, the enabled firmwares will
   also be launched. Refer to the run and installation sections for more
   information.

  ```shell
  cd build/JOD_Smart_Van/{VERSION}
  bash start.sh true
  >> type 'exit' to stop the JOD Smart Van instance
  ```

Additionally, with the development configurations, the firmwares are no longer
downloaded from a URL but copied from local folders. This allows for modifying
the firmwares during development and testing the changes without having to
publish modifications each time.

These configurations assume that the firmware repositories are cloned into the
same folder as the JOD Smart Van project, resulting in the following folder
structure:

```shell
jod_sv_dev
├── com.robypomper.smartvan.jod_smart_van
├── com.robypomper.smartvan.fw_victron
├── com.robypomper.smartvan.fw_sim7600
├── com.robypomper.smartvan.fw_upspack_v3
├── com.robypomper.smartvan.fw_sensehat
├── com.robypomper.smartvan.fw_ioexp
```

If you keep the `VENV` option enabled, remember to create a virtual environment
for each included firmware. For example, go to the directory where you cloned
the firmware and run the following command. The created folder will be included
in the distribution the next time you run the `scripts/build.sh` command:

```shell
cd ../com.robypomper.smartvan.{FW_CODE}
python3 -m venv venv
```

## Update a Smart Van Specs/JOD Pillars

The `struct.jod` file contains **the list of Smart Van specifications** to be
exposed to the mobile app. You can modify this file to add new specifications or
update existing ones (Note: In the John OS Platform, these specifications are
called [Pillars](https://docs.johnosproject.org/references/josp/jod/specs/pillars/),
and they can be of two types: States or Actions).

Each Pillar within the `struct.jod` file, in addition to having a name and path
defined by Smart Van specifications, also **defines how to interact with the
corresponding hardware**. The JOD daemon provides various methods to interact
with the hardware, including reading/writing to files, executing shell commands,
making HTTP requests, connecting to DBUS, and many more.

:::note
JOD Smart Van primarily uses DBUS to communicate with various firmware managing
sensors and actuators in the box.
:::

For example, the specification "Energy > Battery > Percentage" corresponds to a
Pillar in the `struct.jod` file with the same path and name. As this is a
specification for a value (0-100) provided by the Smart Van Box, it corresponds
to a RangeState pillar:

```json
{
  "model": "JOD Smart Van",
  "Percentage": {
    "type": "RangeState",
    "desc": "Battery charge percentage",
    "listener": "dbus://dbus_name=com.victron;dbus_obj_path=/smartsolar_mppt;dbus_iface=com.victron.SmartSolarMPPT;dbus_prop=battery_voltage_percent;init_data=0;",
    "min": "0",
    "max": "100000",
    "step": "1"
  }
}
```

From other properties of the pillar, it can be observed that the associated
firmware exposes the property `battery_voltage_percent` on the DBUS
`com.victron` with the object path `/smartsolar_mppt` and the interface
`com.victron.SmartSolarMPPT`. Those values must be edited according to the
firmware that should be used to manage the underlying hardware.

You can find more examples
of [alternative `struct.jod` files](usage.md#alternative-jod-structures) in the
`dists/resources/configs` folder; or, directly, into a JOD Smart Van
distribution's `configs` dir.

## Add a new firmware

To add a new firmware to the JOD Smart Van distribution, simply include the
firmware as a dependency in the `configs/jod_dist_configs*` files and the two
distribution scripts `pre-startup.sh` and `post-shutdown.sh`.

1. **Add the firmware as a dependency:**
   For each firmware to be included, add the corresponding string to the
   `JOD_DIST_DEPS` variable in the `configs/jod_dist_configs*` files. Firmwares
   can
   be included as links or local folders. In the former case, specify the link
   to the firmware and the destination folder `{URL}@{DEST_DIR}`, while in the
   latter case, specify only the local folder to copy.

  ```shell
  JOD_DIST_DEPS=(
  ...
  "{URL}@{DEST_DIR}"
  )
  ```
  :::note
  In the `configs/jod_dist_configs.sh|ps1` files, links to published firmwares are
  typically added, while in the development configuration file (
  `configs/jod_dist_configs-DEV.sh|ps1`), the local folder containing the firmware
  is added.
  :::
2. **Configure firmware startup/shutdown:**
  For each firmware to be included, configure the
  `dists/resources/scripts/pre-startup.sh` file to start the firmware before the JOD
  daemon starts, and the `dists/resources/scripts/post-shutdown.sh` file to
  terminate the firmware after the JOD daemon termination.
  ```shell
  # Launch firmwares <= dists/resources/scripts/pre-startup.sh
  launch_fw "com.robypomper.smartvan.fw.victron" "" $simulate $venv $inline_logs

  # Kill firmwares <= dists/resources/scripts/post-shutdown.sh
  stop_fw "com.robypomper.smartvan.fw.victron"
  ```
  :::note
  For each firmware, specify the firmware code, the firmware name, and the
  startup options. For more information, refer to the JOD Dist TMPL
  documentation.
  :::

When the new firmware is added, you can update the `struct.jod` file to include
the new specifications provided by the firmware. For more information, refer to
the [Update a Smart Van Specs](#update-a-smart-van-specsjod-pillars) section.
