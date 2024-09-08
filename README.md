# JOD Smart Van Distribution

This is the main repository for the **JOD Smart Van distribution** as part of
the [Smart Van Project](https://www.smartvanbox.org/).<br />
It's based on the [JODDistTMPL](/dists/resources/how_it_works.md#jod-dist-tmpl),
so this repo follows his conventions.

**Dist Name:** JOD Smart Van<br />
**Dist Artifact:** JOD_Smart_Van<br />
**Dist Version:** 1.0.1

[README](README.md) | [CHANGELOG](CHANGELOG.md) | [TODOs](TODOs.md) | [LICENCE](LICENCE.md)

This distribution represent a Smart Van object as defined from
the [Smart Van Project](https://www.smartvanbox.org) website.

As a first version, this distribution contains only the support to some of the
Smart Van Specifications because it's still missing some firmware.<br/>
Actually, the JOD Smart Van includes following firmwares:
* [FW Victron](https://www.smartvanbox.org/docs/software/firmware/fw_victron): v 1.0.3 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.victron/)
* [FW SIM 7600](https://www.smartvanbox.org/docs/software/firmware/fw_sim7600): v 1.0.1 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.sim7600/)
* [FW UPS Pack_V3](https://www.smartvanbox.org/docs/software/firmware/fw_upspack_v3): v 1.0.1 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.upspack_v3/)
* [FW Sense Hat](https://www.smartvanbox.org/docs/software/firmware/fw_sensehat): v 1.0.1 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.sensehat/)
* [FW IO Exp](https://www.smartvanbox.org/docs/software/firmware/fw_ioexp): v 1.0.1 [Sources](https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.ioexp/)

More details on JOD Smart Van distribution, the JOD Dist TMPL and the firmwares
are available at the [How it works](dists/resources/how_it_works.md) page or directly on
the distribution [README.md](dists/resources/README.md) file.

## Build and run

This repo contains a JOD Dist TMPL distribution, so before run the JOD Smart Van
agent, you must build it.
To [build a JOD Smart Van distribution](dists/resources/development.md#build-jod-smart-van-distribution)
you must run the `build.sh` script from the main repository dir.

When you build a JOD distribution, the script downloads the required version of
the JOD daemon and all the specified firmwares as dependencies. Subsequently, it
assembles the destination folder, including the files from the `resources` dir.

For development and testing purposes, you can build a development version
using the `configs/jod_dist_configs-DEV.sh` configuration file. This version is
set up to obtain firmware from folders on the local machine
(e.g., `../com.robypomper.smartvan.fw.victron/`) and execute them in simulation
mode.

```shell
# Standard command
bash scripts/build.sh

# Build development version
bash scripts/build.sh configs/jod_dist_configs-DEV.sh

# Build with debug logs
DEBUG=true bash scripts/build.sh
```

After the build terminates, your JOD Smart Van distribution is ready into the
`build/JOD_Smart_Van/{VERSION}` dir.

Now, you can [deploy](/dists/resources/development.md#deploy-on-remote-machine) and run the
built JOD Smart Van distribution. As described into the distribution's
`build/JOD_Smart_Vane/{VERSION}/README.md` or into the [usage](/dists/resources/usage.md)
page.

Otherwise, check the [Run on development machine](dists/resources/development.md#run-on-development-machine)
section to start an instance of JOD Smart Van that simulate the underlying
hardware.

```bash
cd build/JOD_Smart_Van/{VERSION}
bash start.sh true
 >> type 'exit` to stop the JOD Smart Van instance
```

:::note
Recommendation for Deployment: Choose the Standard Version for Smart Van Box
deployment and Opt for the development version for local machine execution.
:::

## Develop

The development of the JOD Smart Van distribution involves downloading the
source codes. In the case of building a development version, it is necessary to
clone not only the JOD Smart Van project but also all the desired firmwares.

Once the source code is obtained, you
can [customize the distribution structure](dists/resources/development.md#update-a-smart-van-specsjod-pillars)
or [add/update firmware](dists/resources/development.md#add-a-new-firmware) to support new
hardware. To build the distribution, follow the steps below. More information
can be found in
the [Build JOD Smart Van](dists/resources/development.md#build-jod-smart-van-distribution)
section.

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
  Generate the JOD Smart Van distribution. If you are using the development
  configurations, then it will copy the firmwares from local folders. For more
  information, refer to
  the [Build JOD Smart Van distribution](/dists/resources/development.md#build-jod-smart-van-distribution)
  section.
  ```shell
  cd com.robypomper.smartvan.jod_smart_van.git
  bash scripts/build.sh configs/jod_dist_configs-DEV.sh
  ```

Now you are free to customize your JOD Smart Van distribution. However, remember
that for it to work seamlessly with
the [SV Mobile App](https://www.smartvanbox.org/docs/software#sv-mobile-app),
your customizations must adhere to
the [Smart Van specifications](https://www.smartvanbox.org/docs/specs).

## Collaborate

This project is part of the [Smart Van Project](https://www.smartvanbox.org),
and it's published under an Open Source licence to allow the community to
contribute to the project.

If you want to contribute to the project, you can start by reading the
[Contribution Guidelines](https://www.smartvanbox.org/collaborate) page.
Otherwise, you can clone current repository and start to customize your own
JOD Smart Van distribution. Check out the project's structure and 'how to work
on it', on the [Development](/dists/resources/development.md) page.
