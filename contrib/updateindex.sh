#!/bin/bash

function die() {
    echo "$1" >&2
    exit 1
}

function warn() {
    echo "$1" >&2
}

CONF=/etc/channelarchiver/daemon.conf
CDIR="$(dirname "$CONF")"

DTD=/usr/share/xml/channelarchiver/indexconfig.dtd

source "$CONF"

function create_xml() {
    out="$1"
    shift

    unset ifiles
    if [ "$1" = "-" ]
    then
        while read ff
        do
            ifiles="$ifiles $ff"
        done
    else
        ifiles="$@"
    fi

    #echo "Create $out from $ifiles"

    if ArchiveIndexMakeConfig -d $DTD $ifiles > "$out.tmp"
    then
        if xmllint --noout --valid "$out.tmp"
        then
            mv "$out.tmp" "$out"
        else
            die "Generated invalid index config $out"
        fi
    else
        rm "$out.tmp"
        die "Failed to generate index config $out"
    fi
}

[ -n "$BASE_DIR" ] || die "Config does not specify BASE_DIR ($BASE_DIR)"
[ -d "$BASE_DIR" ] || die "Missing directory: $BASE_DIR"

YYYY=`date +%Y`

for dd in "$CDIR"/*
do
    [ -d "$dd" ] || continue
    [ "`basename "$dd"`" = "example" ] && continue

    [ -r "$dd/daemon.conf" ] || continue

    name=`basename $dd`

    # config present, but not data yet
    [ -d "$BASE_DIR/$name" ] || continue

    # Handle current year

    if [ -h "$BASE_DIR/$name/current_index" ]
    then
        exclude=$(readlink -f "$BASE_DIR/$name/current_index")
    else
        exclude=/dev/null
    fi

    pushd "$BASE_DIR/$name/$YYYY" >/dev/null || die "Failed to cd to $BASE_DIR/$name/$YYYY"

    #TODO: Test that size of found files is < 2GB (aka 2^32)

    if find . -name index -a \
       -not -samefile "$exclude" | \
       create_xml "$BASE_DIR/$name/$YYYY/year_index.xml" -
    then
        echo -n
    else
        echo "Failed to create year index config for $name" >&2
        continue
    fi

    ArchiveIndexTool year_index.xml year_index \
    || warn "Failed to create archive $BASE_DIR/$name/$YYYY/year_index" && continue

    popd >/dev/null

    # handle previous years

    for year in "$BASE_DIR/$name/"*
    do
        [ -d "$year" ] || continue
        y=`basename "$year"`
        [ "$y" -eq "$YYYY" ] && continue
        if [ "$y" -gt "$YYYY" ]; then
            echo "The future is now!  Found archive: $year" >&2
            continue
        fi

        [ -f "$year/year_index" ] && continue

        find "$year" -name index | \
        create_xml "$year/year_index.xml" - || die "Failed to create $y index config"

        pushd "$year" >/dev/null || die "Failed to cd to $year"

        ArchiveIndexTool year_index.xml year_index || die "Failed to create archive $year/year_index"

        popd >/dev/null

    done || warn "Failed to generate past config"

done || die "Fail"
