DESCRIPTION = "My Custom Kernel Module!"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=12f884d2ae1ff87c09e5b7ccc2c4ca7e"

inherit module

PR = "r0"

SRC_URI = "file://Makefile \
           file://my_hello_mod.c \
           file://COPYING \
          "

S = "${WORKDIR}"
