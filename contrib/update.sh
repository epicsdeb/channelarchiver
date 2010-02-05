#!/bin/bash

/usr/share/channelarchiver/updateindex.sh

if [ -x /usr/share/channelarchiver/genserver.sh ]
then
    /usr/share/channelarchiver/genserver.sh
fi
