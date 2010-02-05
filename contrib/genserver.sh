#!/bin/bash

function die() {
    echo "$1" >&2
    exit 1
}

CONF=/etc/channelarchiver/daemon.conf
CDIR="$(dirname "$CONF")"

DTD=/usr/share/xml/channelarchiver/serverconfig.dtd

source "$CONF"

YYYY=`date +%Y`

[ -n "$BASE_DIR" ] || die "Config does not specify BASE_DIR ($BASE_DIR)"
[ -d "$BASE_DIR" ] || die "Missing directory: $BASE_DIR"

OUT="$BASE_DIR/dataserver.xml"
TMP="$OUT.tmp"

touch "$TMP" || die "Can't write to $TMP"

cat << EOF > "$TMP"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE serverconfig SYSTEM "$DTD">
<serverconfig>
EOF

IDX=1

for dd in "$CDIR"/*
do
    [ -d "$dd" ] || continue
    [ "`basename "$dd"`" = "example" ] && continue

    [ -r "$dd/daemon.conf" ] || continue

    name=`basename $dd`

    if [ -f "$BASE_DIR/$name/current_index" ]; then
        cat << EOF >> "$TMP"
<archive>
  <key>$IDX</key>
  <name>$name/Current</name>
  <path>$BASE_DIR/$name/current_index</path>
</archive>
EOF
        IDX=`expr $IDX \+ 1`
    fi
done


for dd in "$CDIR"/*
do
    [ -d "$dd" ] || continue
    [ "`basename "$dd"`" = "example" ] && continue

    [ -r "$dd/daemon.conf" ] || continue

    name=`basename $dd`

    for year in "$BASE_DIR/$name/"*
    do
        [ -d "$year" ] || continue
        y=`basename "$year"`

        [ -f "$year/year_index" ] || continue

        cat << EOF >> "$TMP"
<archive>
  <key>$IDX</key>
  <name>$name/$y</name>
  <path>$year/year_index</path>
</archive>
EOF
        IDX=`expr $IDX \+ 1`
    done

done || die "Fail"

cat << EOF >> "$TMP"
</serverconfig>
EOF

if xmllint --noout --valid "$TMP"
then
    mv "$TMP" "$OUT" || die "Failed to create $OUT"
else
    echo "Invalid out"
    rm -f "$TMP"
    exit 1
fi
