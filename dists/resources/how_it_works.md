# JOD Smart Van - How it works

## JOD Dist TMPL

The [JOD Dist TMPL](https://docs.johnosproject.org/references/tools/jod_dist_template/)
is a template for creating a JOD distribution. It contains all the necessary
configuration files and scripts to build a JOD distribution. Then the distribution
can be deployed and executed on a device.

In the Smart Van project, **the JOD Dist TMPL is used as base for the JOD Smart
Van project** and allows **to build a JOD Smart Van distribution** for the Smart
Van Box device.

The JOD Dist TMPL project is organized with the following directory structure:

* `configs/`: contains the configuration files used to build the JOD Smart Van
  distribution via the JOD Dist TMPL scripts
* `dists/`: files that will be copied into the distribution
* `scripts/`: contains the scripts to build, install and publish the JOD Smart Van
  distribution

:::note
Some of those dirs and files are used to customize the JOD Dist TMPL to JOD
Smart Van project needs. Others, like the two main scripts dirs (`scripts` and
`dists/scripts`) are inherit from the JOD Dist TMPL project and must not be
modified.
:::

In order to build a JOD Smart Van distribution, you must run the `build.sh`
script, then you can find the built distribution into
the `build/{DIST_NAME}}/{DIST_VER}` dir. Where `DIST_NAME` and `DIST_VER` are
defined into the `configs/jod_dist_configs*` files.

```bash
# Standard command
bash scripts/build.sh

# Build development version
bash scripts/build.sh configs/jod_dist_configs-DEV.sh
```

More info on the JOD Dist TMPL build process and life-cycle can be found into
the [JOD Dist TMPL documentation](https://docs.johnosproject.org/references/tools/jod_dist_template/distribution_life_cycle).

:::warning
Theoretically, the JOD Dist TMPL support all 3 major OS (Linux, macOS and
Windows). But, in the Smart Van project, we only support Linux because his
firmwares are Python scripts, strictly related to specific hardware, tested only
on Linux.
:::

## Smart Van Specs vs. JOD Pillars

The Smart Van Specs define the endpoints that the Smart Van Box must expose to
the Smart Van Mobile App. Using the Smart Van Specs, the Smart Van Mobile App
can interact with the Smart Van Box and enable/disable the available features
based on the Smart Van Specs provided by the Smart Van Box.

When you customize
the [JOD Smart Van's structure](development.md#update-a-smart-van-specsjod-pillars)
you must ensure that the JOD Smart Van agent exposes the same endpoints defined
by the Smart Van Specs. Other Pillars will be ignored by the Mobile App

For the full list of the Smart Van specification see 
the [official documentation](https://smartvan.johnosproject.org/docs/specs).

## Smart Van Box communication to SV Mobile App
...DIRECT/CLOUD see https://docs.johnosproject.org/references/josp/jod/comm

## Hardware, firmwares, JOD agent and Mobile App flow
... communication flow
    STATES -> hardware > firmware > JOD SV > SV Mobile App
    ACTIONS -> SV Mobile App > JOD SV > firmware > hardware
... startup/shutdown flow
    dists/resources/scripts/pre-startup.sh
    dists/resources/scripts/post-shutdown.sh
... JOD dependencies (and Prod/Dev versions)
    inclusion in configs/jod_dist_configs 

## Smart Van Box owner registration and sharing
... JOD access control

## WiFi AP
... (NOT JOSP) WIFi AP