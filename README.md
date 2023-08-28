# JOD Distribution TEMPLATE - 1.0.3

The JOD Distribution TEMPLATE helps Makers to generates custom JOD Distributions that can be executed on the local machine, deployed on remote objects or shared with other users.

A JOD Distribution can be generated from scratch simply with following steps
1. [configure](#configure)
1. [build](#build)
1. [install](#install) or [publish](#publish)

* Current version: 1.0.3</td></tr>
* References: [JOD_Dist_TEMPLATE @ JOSP Docs](href="https://www.johnosproject.org/docs/references/jod_dists/jod_dist_template/)
* Repository: [com.robypomper.josp.jod.template @ Bitbucket](https://bitbucket.org/johnosproject_shared/com.robypomper.josp.jod.template/)

## Configure

If you haven't already, download and extract the JOD Distribution TEMPLATE from the [JOSP Docs](https://www.johnosproject.org/docs/index.html) website.

```shell
$ curl -fo JOD_Dist_TMPL-{VER}.tgz \
      https://bitbucket.org/johnosproject_shared/com.robypomper.josp.jod.template/downloads/JOD_Dist_TMPL-{VER}.tgz
$ tar zxvf JOD_Dist_TMPL-{VER}.tgz
$ mv JOD_Dist_TMPL-{VER} {MY_JOD_DIST}
```

Now you can edit {MY_JOD_DIST} files to your needs.

### JOD Distribution configs

First configure mandatory properties to the ```configs/jod_dist_configs.(sh|ps1)``` files. Those files contain most distribution configurations from distribution info (like his name or version) to JOD instance settings. Here the groups that are organized those configs:
* JOD Distribution: set distribution's name, artifact and version
* John Cloud Platform: set JCP environment and object's credentials
* JOD Object: JOD agent's version and other configs for jod.yml file to include in distribution
* JOD Firmware: change JOD agent's executor to interact with hardware and external systems. 

When develop your JOD distribution, you can set the ```test-client-obj``` client id and ```2d1f9b96-70d3-443b-b21b-08a401ddc16c``` secret as JCP credentials. This allows your JOD distribution to connect to the [Stage Public JCP](https://stage.johnosproject.org/frontend/index.html) (set the```DIST_JCP_ENV="stage"```). When you need to release your distribution and use it on [Production Public JCP](https://www.johnosproject.org/frontend/index.html), please request distribution credential sending an email to [tech@johnosproject.com](mailto:tech@johnosproject.com). 

Some of ```jod_dist_configs.(sh|ps1)```'s properties are useful when makers must test their distribution. For example makers can set ```DIST_JOD_NAME```, ```DIST_JOD_ID```and ```DIST_JOD_OWNER```; so every time he builds and execute the distribution, resulting object will recognize as owned object and don't require the [object's owner registration](https://www.johnosproject.org/docs/Guides/End%20Users/Object%201st%20Setup/Register_object_owner) procedure. 

Moreover, in the ```jod_dist_configs.(sh|ps1)``` files, makers can change JOD
executors to be loaded. JOD Executors are JOD's components that interface the
JOD agent with underling HW or external system. Makers can load only required
executors or add his own, see [create JOD Executor]() for more info on how to
develop a custom JOD Executor. 

### JOD Structure

After configuring your JOD distribution, you can start customizing object's structure. Object's structure define which states and which actions your distribution will expose as a JOSP Object.
Customize and test your ```configs/struct.jod``` file ... Visit JOSP Docs for detailed guide on [configure object's structure](https://www.johnosproject.org/docs/Guides/Makers/John%20Object%20Agent/Configure_JOD_Struct).

### Pre/POST scripts

It's also possible, for makers, add custom scripts that will execute on JOD instance management actions, such as start/stop or install/uninstall. This scripts can be executed before or after the JOD instance action.

The JOD Distribution TEMPLATE contains PRE/POST script examples. Check out the [```$JOD_DIST_TMPL/dists/resources/scripts```](https://bitbucket.org/johnosproject_shared/com.robypomper.josp.jod.template/src/master/src/dists/resources/scripts), here you can find all PRE/POST script examples. You can find a list of all PRE/POST scripts at [JOD Distribution commands](https://bitbucket.org/johnosproject_shared/com.robypomper.josp.jod.template/src/master/docs/dists/dists.md#pre-post-scripts).

### Extra files

The ```dists/resources``` dir contains al static file that will include in the JOD Distribution. So makers are free to add their own files (scripts, docs, firmware, etc..) to this directory.

The JOD Distribution TEMPLATE provide common files example like:
* log4j2.xml: example of custom log4j2.xml file used by the JOD instance
* README.md: template file for README.md file for a JOD Distribution
* CHANGELOG.md: template file for CHANGELOG.md file for a JOD Distribution
* TODO.ms: template file for TODO.md file for a JOD Distribution
* docs: directory to use for JOD distribution's documentation
* media: directory to use for JOD distribution's media files

### Resuming

```shell
$ cd {MY_JOD_DIST}

# Configure JOD Distribution build's configs, JOD Instance configs and object structure
$ nano configs/jod_dist_configs.sh    # JOD Distribution configs for bash scripts
$ nano configs/jod_dist_configs.ps1   # JOD Distribution configs for powershell scripts
$ nano dists/configs/struct.jod       # JOD structure

# Enable and customize PRE-POST scripts
$ cd dists/resources/scripts/
$ mv (pre|post)-*.sh_EXMPL (pre|post)-*.sh && nano (pre|post)-*.sh

# Add firmware files
$ cp {FIRMWARE_FILES} dists/resources/scripts/hw

# Add extra files and docs
$ cd dists/resources/
$ mv log4j2.xml_EXMPL log4j2.xml && nano log4j2.xml
$ mv README.md_EXMPL README.md && nano README.md
$ cp {EXTRA_FILES} .
$ cd -
```

## Build

Once you configured your JOD Distribution, you can build it with the [build](https://bitbucket.org/johnosproject_shared/com.robypomper.josp.jod.template/src/master/docs/tmpl/build.md) script from [JOD Template commands](https://bitbucket.org/johnosproject_shared/com.robypomper.josp.jod.template/src/master/docs/tmpl/tmpl.md):

For Bash:
```shell
$ bash scripts/build.sh
```

For Powershell:
```powershell
$ powershell scripts/build.ps1
```

The generated JOD Distribution is build in ```build/$DIST_ARTIFACT/$DIST_VER``` folder.

## Install

The JOD Distribution installation, in this context, means copy built JOD Distribution's files in another directory with the purpose to create a working copy of built JOD Distribution. Because of that, after installation, you can execute JOD Distribution's scripts in the installed folder and manage (start/stop, install/uninstall) that specific JOD Instance.

**NB:** This command is intended to use for JOD distribution testing purposes. To install a JOD Distribution on a remote object or distribute it, please see the [Publish](#publish) section.

```shell
$ bash scripts/install.sh
```

This command, copy generated JOD Distribution into ```envs/$DIST_ARTIFACT-$DIST_VER/$4DIGIT_RANDOM_NUMBER``` directory. To specify
different JOD Distribution's configs file or installation dir, please use
```install.sh``` params.

```shell
$ bash scripts/install.sh configs/configs.sh envs/my-jod-object
```

## Publish

When ready, a JOD Distribution con be published. That means generate distributable files (tgz and zip) and upload to the [JOSP Docs > JOD Distributions list](https://www.johnosproject.org/docs/references/jod_dists/) page.

To upload the distribution to the JOD Distributions list, you must set valid credentials for JCP and JOSP JOD Distributions repository in the ```configs/jod_dist_configs.(sh|ps1)``` file. JOSP JOD Distributions repository credentials are optionals, if not set the upload step is skip.

When the JOD distribution's distributable files are generated, you can share them with other user or download them on remote object (p.e. a RaspberryPi) and use it as IoT object.
