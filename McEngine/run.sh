#!/bin/bash

NAME="McEngine"
BUILD="Release/Linux"

WRK="build"



FULLPATH=$(dirname "$(readlink -f "$0")")
echo "FULLPATH = $FULLPATH"

cd "$FULLPATH/$BUILD"
chmod +x $NAME

cd "$FULLPATH/$WRK"
"./../$BUILD/$NAME" $1

