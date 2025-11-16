#!/usr/bin/env bash

. ./vars.sh

if [[ ! ( -n "$RWHOD_SERVICE" &&
          -n "$LAUNCHD_PLIST" &&
          -n "$LAUNCHDAEMONS_FOLDER" &&
          -n "$INSTALL_PLIST_PATH" &&
          -n "$RWHOD_SPOOL" &&
          -n "$RWHOD_PATH" &&
          -n "$MAN_PATH" &&
          -n "$RTOOLS_PATH" ) ]]; then
    echo "Error, check 'vars.sh'."
    exit 1
fi

if [[ ! ( -f "out/rwhod" &&  -f "out/rwho" && -f "out/ruptime" ) ]]; then
    echo "Error, no binaries found."
    exit 1
fi

# spool
sudo mkdir -p $RWHOD_SPOOL
sudo chown daemon:daemon $RWHOD_SPOOL
sudo chmod 755 $RWHOD_SPOOL

# bin install
sudo mkdir -p $RWHOD_PATH $RTOOLS_PATH
sudo /usr/bin/install -m 755 -o root -g wheel out/rwhod $RWHOD_PATH
sudo /usr/bin/install -m 755 -o root -g wheel out/rwho $RTOOLS_PATH
sudo /usr/bin/install -m 755 -o root -g wheel out/ruptime $RTOOLS_PATH

# manuals
sudo mkdir -p $MAN_PATH/man1 $MAN_PATH/man8
sudo /usr/bin/install -m 644 -o root -g wheel man/rwhod.8 $MAN_PATH/man8
sudo /usr/bin/install -m 644 -o root -g wheel man/rwho.1 $MAN_PATH/man1
sudo /usr/bin/install -m 644 -o root -g wheel man/ruptime.1 $MAN_PATH/man1

# launchd plist
sudo /usr/bin/install -m 644 -o root -g wheel launchd/$LAUNCHD_PLIST $LAUNCHDAEMONS_FOLDER

# launchctl
sudo launchctl enable system/$RWHOD_SERVICE
sudo launchctl bootstrap system $INSTALL_PLIST_PATH
sudo launchctl start $RWHOD_SERVICE

# check
sudo launchctl list | grep -e '^PID' -e $RWHOD_SERVICE
