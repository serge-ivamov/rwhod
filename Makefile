PROJECT_VERSION := $(shell cat version)

RWHOD_SERVICE = ru.ec.rwhod
LAUNCHD_PLIST = ${RWHOD_SERVICE}.plist
LAUNCHDAEMONS_FOLDER = /Library/LaunchDaemons
INSTALL_PLIST_PATH = ${LAUNCHDAEMONS_FOLDER}/${LAUNCHD_PLIST}

RWHOD_SPOOL = /var/rwho
RWHOD_PATH = /usr/local/sbin
RTOOLS_PATH = /usr/local/bin
MAN_PATH = /usr/local/man

DEF_RWHOD_SPOOL = -DPATH_RWHODIR=\"/var/rwho\"
DEF_RWHOD_DEBUG_SPOOL = -DPATH_RWHODIR=\"/tmp/rwho\"

CFLAGS = -Wall -fPIE
LD_FLAGS = -dead_strip
ARCH_UNI = -arch x86_64 -arch arm64

.PHONY: all clean install uninstall pkg

start:
	@echo Use: make install / uninstall

all: out/rwhod out/rwho out/ruptime out/rwhod.debug out/rwho.debug out/ruptime.debug

out/rwhod: src/rwhod.c
	cc ${CFLAGS} ${LD_FLAGS} ${ARCH_UNI} ${DEF_RWHOD_SPOOL} -o out/rwhod src/rwhod.c
out/rwho: src/rwho.c
	cc ${CFLAGS} ${LD_FLAGS} ${ARCH_UNI} ${DEF_RWHOD_SPOOL} -o out/rwho src/rwho.c
out/ruptime: src/ruptime.c
	cc ${CFLAGS} ${LD_FLAGS} ${ARCH_UNI} ${DEF_RWHOD_SPOOL} -o out/ruptime src/ruptime.c
out/rwhod.debug: src/rwhod.c
	cc ${CFLAGS} ${LD_FLAGS} ${ARCH_UNI} -DDEBUG ${DEF_RWHOD_DEBUG_SPOOL} -o out/rwhod.debug src/rwhod.c
out/rwho.debug: src/rwho.c
	cc ${CFLAGS} ${LD_FLAGS} ${ARCH_UNI} -DDEBUG ${DEF_RWHOD_DEBUG_SPOOL} -o out/rwho.debug src/rwho.c
out/ruptime.debug: src/ruptime.c
	cc ${CFLAGS} ${LD_FLAGS} ${ARCH_UNI} -DDEBUG ${DEF_RWHOD_DEBUG_SPOOL} -o out/ruptime.debug src/ruptime.c

install-rwhod-spool:
	sudo mkdir -p ${RWHOD_SPOOL}
	sudo chown daemon:daemon ${RWHOD_SPOOL}
	sudo chmod 755 ${RWHOD_SPOOL}
install-rwhod: out/rwhod
	sudo mkdir -p ${RWHOD_PATH}
	sudo /usr/bin/install -m 755 -o root -g wheel out/rwhod ${RWHOD_PATH}
install-rwho: out/rwho
	sudo mkdir -p ${RTOOLS_PATH}
	sudo /usr/bin/install -m 755 -o root -g wheel out/rwho ${RTOOLS_PATH}
install-ruptime: out/ruptime
	sudo mkdir -p ${RTOOLS_PATH}
	sudo /usr/bin/install -m 755 -o root -g wheel out/ruptime ${RTOOLS_PATH}
install-man:
	sudo mkdir -p ${MAN_PATH}/man1 ${MAN_PATH}/man8
	sudo /usr/bin/install -m 644 -o root -g wheel man/rwhod.8 ${MAN_PATH}/man8
	sudo /usr/bin/install -m 644 -o root -g wheel man/rwho.1 ${MAN_PATH}/man1
	sudo /usr/bin/install -m 644 -o root -g wheel man/ruptime.1 ${MAN_PATH}/man1
install-launchd: out/rwhod
	sudo /usr/bin/install -m 644 -o root -g wheel launchd/${LAUNCHD_PLIST} ${LAUNCHDAEMONS_FOLDER}
launch-enable:
	sudo launchctl enable system/${RWHOD_SERVICE}
	sudo launchctl bootstrap system ${INSTALL_PLIST_PATH}
launch-start:
	sudo launchctl start ${RWHOD_SERVICE}

launch-stop:
	sudo launchctl stop ${RWHOD_SERVICE}
launch-disable:
	sudo launchctl bootout system/${RWHOD_SERVICE}
	sudo launchctl disable system/${RWHOD_SERVICE}
uninstall-rwhod:
	sudo rm -f ${RWHOD_PATH}/rwhod
uninstall-rwho:
	sudo rm -f ${RTOOLS_PATH}/rwho
uninstall-ruptime:
	sudo rm -f ${RTOOLS_PATH}/ruptime
uninstall-man:
	sudo rm -f ${MAN_PATH}/man8/rwhod.8
	sudo rm -f ${MAN_PATH}/man1/rwho.1
	sudo rm -f ${MAN_PATH}/man1/ruptime.1
uninstall-launchd:
	sudo rm -f ${INSTALL_PLIST_PATH}

launch-status:
	sudo launchctl list | grep -e '^PID' -e ${RWHOD_SERVICE}

log-rwhod:
	log stream --predicate 'process == "rwhod"'
log-rwhod-1d:
	log show --predicate 'process == "rwhod"' --last 1d

clean:
	rm -f out/rwhod out/rwho out/ruptime out/rwhod.debug out/rwho.debug out/ruptime.debug
	rm -f pkg-*.tgz
	rm -rf pkg/

pkg:	clean out/rwhod out/rwho out/ruptime
	mkdir -p pkg
	cp -r launchd man out installer.sh uninstaller.sh vars.sh pkg
	tar zcvf pkg-${PROJECT_VERSION}.tgz pkg/

install: install-rwhod-spool install-rwhod install-rwho install-ruptime install-man install-launchd launch-enable launch-start launch-status
uninstall: launch-stop launch-disable uninstall-launchd uninstall-rwhod uninstall-rwho uninstall-ruptime uninstall-man
