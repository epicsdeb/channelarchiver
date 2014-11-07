#!/bin/bash
set -e -x

function die() {
    echo "$1" >&2
    exit 1
}

function hashme() {
    # take a CRC32 of the first arguement
    # modulo 0x10000 to make it smaller
    echo -n "$1" | python -c 'import sys,zlib;sys.stdout.write(str(zlib.crc32(sys.stdin.readline())%0x10000))'
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

for idx in "$BASE_DIR"/*/current_index "$BASE_DIR"/*/*/year_index
do
    DIR="$(dirname "$idx")"

    if [ -r "$DIR/dataserver-key.txt" ]
    then
        # read existing ID
        IDX=`awk '{printf "%s", $1;exit}' "$DIR/dataserver-key.txt"`
    else
        # generate a new ID
        case "$idx" in
        */current_index) IDX=`hashme "$name"`;;
        */year_index)    IDX=`hashme "$name/$y"`;;
        *)               IDX=invalid ;;
        esac
        echo "$IDX" > "$DIR/dataserver-key.txt" \
        || echo "Warning: can't to write $IDX to '$DIR/dataserver-key.txt'" >&2
    fi

    case "$idx" in
    */current_index) name="$(basename "$DIR")/Current" ;;
    */year_index)
       YEAR="$(basename "$DIR")"
       ARCH="$(basename "$(dirname "$DIR")")"
       name="$ARCH/$YEAR"
       ;;
    *) continue;;
    esac

    echo "$idx: $IDX $name"

    cat << EOF >> "$TMP"
<archive>
  <key>$IDX</key>
  <name>$name</name>
  <path>$idx</path>
</archive>
EOF

done || die "Fail"

cat << EOF >> "$TMP"
</serverconfig>
EOF

if xmllint --noout --valid "$TMP"
then
    mv "$TMP" "$OUT" || die "Failed to create $OUT"
else
    echo "Invalid out"
    exit 1
fi
