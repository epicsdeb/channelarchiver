#!/bin/bash

if [ "`whoami`" != channelarchiver ]; then
    sudo -u channelarchiver $0 "$@"
    exit $?
fi

/usr/share/channelarchiver/updateindex.sh

if [ -x /usr/share/channelarchiver/genserver.sh ]
then
    /usr/share/channelarchiver/genserver.sh
fi
