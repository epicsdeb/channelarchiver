#!/bin/bash

function die() {
	echo "$1" >&2
	exit 1
}

CONF=/etc/channelarchiver/daemon.conf
CDIR="$(dirname "$CONF")"

DTD=/usr/share/xml/channelarchiver/ArchiveDaemon.dtd

OUT="$1"
TMP="$OUT.tmp"
shift

trap "rm $TMP" HUP TERM INT KILL

PCNT=0

source "$CONF"

[ -n "$BASE_DIR" ] || die "Config does not specify BASE_DIR ($BASE_DIR)"

if [ ! -d "$BASE_DIR" ]; then
	install -d "$BASE_DIR" || die "Failed to create $BASE_DIR"
fi

touch "$TMP" || die "Can't write to $TMP"

cat << EOF > "$TMP"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE daemon SYSTEM "$DTD">
<daemon>
   <port>$DAEMON_PORT</port>

EOF

for dd in "$CDIR"/*
do
	[ -d "$dd" ] || continue
	[ "`basename "$dd"`" = "example" ] && continue

	[ -r "$dd/daemon.conf" ] || continue

	[ -r "$dd/engine.xml" ] || die "Engine '$(basename "$dd")' missing $dd/engine.xml"

	PORT=$(expr $BASE_PORT \+ $PCNT)
	PCNT=$(expr $PCNT \+ 1)

	CONF="$dd/engine.xml"
	DIR="$BASE_DIR/$(basename "$dd")"
	unset NAME

	(source $dd/daemon.conf; cat << EOF >> "$TMP")
   <engine directory='$DIR'>
      <desc>$NAME</desc>
      <port>$PORT</port>
      <config>$CONF</config>
      <restart>
        <period type='$RESTART_MODE'>$RESTART_TIME</period>
        <action>/usr/share/channelarchiver/update.sh</action>
      </restart>
      <dataserver><host>$DATA_SERVER</host></dataserver>
   </engine>
EOF

done || die "Fail"


cat << EOF >> "$TMP"
</daemon>
EOF

if xmllint --noout --valid "$TMP"
then
	mv "$TMP" "$OUT" || die "Failed to create $OUT"
else
	echo "Invalid out"
	rm -f "$TMP"
	exit 1
fi
