#!/bin/bash

if [ "`whoami`" != channelarchiver ]; then
    sudo -u channelarchiver $0 "$@"
    exit $?
fi

/usr/share/channelarchiver/updateindex.sh "$1"

if [ -x /usr/share/channelarchiver/genserver.sh ]
then
    /usr/share/channelarchiver/genserver.sh
fi
