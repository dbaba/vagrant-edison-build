vagrant-edison-build
===

This vagrant stuff helps you to build kernel modules (.ko files) running on the intel's iotdk complete image (poky-edison). You can copy them into your edison without replacing entire image.

## Prerequisites

1. Vagrant 1.8.1+
1. VirtualBox 5+
1. 4GiB RAM and 2 CPU cores for a vagrant box ... You can modify it in Vagrantfile
1. High-speed Internet connection

## Ttested Edison Image Version

[Release 2.1](https://software.intel.com/en-us/iot/hardware/edison/downloads)(poky-edison)

### VM memory and CPU allocation

Modify `vb.memory` for RAM size and `vb.cpus` for core size in `Vagrantfile`.

```ruby
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true

    # Customize the amount of memory on the VM:
    vb.memory = "4096"
    # Customize the cpu size on the VM:
    vb.cpus = 2
  end
```

## How to use

Clone the project and launch it with Vagrant.
```bash
(host)   $ git clone https://github.com/dbaba/vagrant-edison-build.git
(host)   $ cd vagrant-edison-build
(host)   $ vagrant up
```

SSH to the vagrant box.
```bash
(host)   $ vagrant ssh
```

You can list the config values by running the command.
```bash
(vagrant)$ ./config_get.sh CONFIG_USB_NET_CDCETHER
~/edison/edison-src/meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files ~
[defconfig]
1207:CONFIG_USB_NET_CDCETHER=m
```

You can configure the kernel config as you like.
```bash
(vagrant)$ ./config_set.sh CONFIG_USB_NET_CDCETHER m
~/edison/edison-src/meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files ~
==== BEFORE ===
[defconfig]
1207:# CONFIG_USB_NET_CDCETHER is not set
==== AFTER ===
[defconfig]
1207:CONFIG_USB_NET_CDCETHER=m
```

You can reset the kernel config modifications by the following command.
```bash
(vagrant)$ ./config_rset.sh
~/edison/edison-src/meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files ~
Resetting configuration
[defconfig]
Done
```

Now time to build. Run the following command.

```bash
(vagrant)$ source ./build.sh
```

This will take a couple of hours or more depending on your network bandwidth and allocated hardware resources.

It took 2 hours and 10 minutes for the first build with 2.8 GHz Intel Core i7 and 16GiB RAM (4GiB RAM and 2 cpus were allocated for VM). The second build after adding 3 modules was finished around 15 minutes though.

The shell script takes you to `/mnt/edison` where the rootfs is expanded.

The command output looks like as follows.

```bash
~/edison/edison-src ~

### Shell environment set up for builds. ###

You can now run 'bitbake <target>'

Common targets are:
    core-image-minimal
    core-image-sato
    meta-toolchain
    adt-installer
    meta-ide-support

You can also run generated qemu images with a command like 'runqemu qemux86'
Start building at Wed Oct 28 14:16:04 UTC 2015

(snip)

Terminated building at Wed Oct 28 17:00:33 UTC 2015
~
Done. You're now able to explore the rootfs from here! => /mnt/edison
Copy files to /vagrant, and you can get them from the host machine without SCP.
```

Then try to find a kernel module file, `cdc_ether.ko` for instance.

```bash
(vagrant)$ sudo find -name "cdc_ether.ko"
./lib/modules/3.10.17-poky-edison+/kernel/drivers/net/usb/cdc_ether.ko
```

See [HOWTO: make your driver load automatically at poky boot](https://communities.intel.com/message/289417#289417) for installing the kernel files.

### Where are bitbake building files?

You can find the rootfs and other files in `${HOME}/edison/edison-src/out/linux64/build/tmp/deploy/images/edison/`.

### How to use the previous release source code?

Edit `setup.sh` and modify `SOURCE_URL`, then `vagrant destroy -f; vagrant up`.

## Helpful Resources

- [HOWTO: make your driver load automatically at poky boot](https://communities.intel.com/message/289417#289417)
- [Version Magic Error](https://github.com/LGSInnovations/Edison-Ethernet/blob/master/guides/version-magic-error.md)

## `wget` and POODLE issue
The preinstalled version of `wget` is too old to handle non-SSLv3 connection, e.g. downloading files from download.xdk.intel.com where SSLv3 is disabled for fixing POODLE don't work at all. In fact, I got the following error while building the kernel.

    ERROR: Fetcher failure: Fetch command failed with exit code 4, output:
    OpenSSL: error:14077410:SSL routines:SSL23_GET_SERVER_HELLO:sslv3 alert handshake failure
    Unable to establish SSL connection.`

In order to avoid the error, I added a simple wrapper script [`fetch_cmd`](fetch_cmd) using `curl`, as well as `wget`, which is able to handle such the connection, and modify `FETCHCMD_wget` variable in the `bitbake.conf`. The script uses `curl` only when `wget` fails.

## Revision History

* ?.?.?
  - Fix an issue where `bitbake` failed to download xdk-daemon-0.0.35.tar.bz2 with `wget` command
* 1.0.1
  - renamed
* 1.0.0
  - Initial Release
