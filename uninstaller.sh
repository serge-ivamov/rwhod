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
    echo "Error, check vars.sh"
    exit 1
fi

# launchctl
sudo launchctl stop $RWHOD_SERVICE
sudo launchctl bootout system/$RWHOD_SERVICE
sudo launchctl disable system/$RWHOD_SERVICE

# launchd-plist
sudo rm -f $INSTALL_PLIST_PATH

# bin uninstall
sudo rm -f $RWHOD_PATH/rwhod
sudo rm -f $RTOOLS_PATH/rwho
sudo rm -f $RTOOLS_PATH/ruptime

# manuals
sudo rm -f $MAN_PATH/man8/rwhod.8
sudo rm -f $MAN_PATH/man1/rwho.1
sudo rm -f $MAN_PATH/man1/ruptime.1
