#!/bin/bash

NAME="McEngine"
BUILD="Linux Release"

SRC="src"
LIB="libraries"

CXX="g++"
CC="gcc"
LD="g++"

CXXFLAGS="-std=c++11 -O3 -Wall -c -fmessage-length=0 -Wno-sign-compare -Wno-unused-local-typedefs -Wno-reorder -Wno-switch"
CFLAGS="-O3 -Wall -c -fmessage-length=0"

LDFLAGS=""
LDFLAGS2=("-fuse-ld=gold" "-static-libstdc++" "-static-libgcc" "-Wl,-rpath=.") # NOTE: -fuse-ld=gold to get rid of weird ".dynsym local symbol at index 2 (>= sh_info of 2)" warning even though it compiles
LDLIBS="-ldiscord-rpc -lsteam_api -lcurl -lz -lX11 -lXi -lGL -lGLU -lGLEW -lfreetype -lbass -lbass_fx -lOpenCL -lBulletSoftBody -lBulletDynamics -lBulletCollision -lLinearMath -lenet -lpthread -ljpeg"



STARTTIMESECONDS=$SECONDS

RESET='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'

ARG1="$1"

FULLPATH=$(dirname "$(readlink -f "$0")")
echo "FULLPATH = $FULLPATH"

if [ "$ARG1" != "incremental" ] || [ ! -d "$BUILD" ]; then
	echo "Creating $FULLPATH/$BUILD/ directory ..."
	rm -rf "$FULLPATH/$BUILD"
	mkdir "$FULLPATH/$BUILD"
fi

echo "Collecting C++ files ..."
cppfiles=()
while IFS= read -r -d '' cppfile; do
	echo "$cppfile"
	cppfiles+=("$cppfile")
done < <(find "$FULLPATH/$SRC/" -type f -name "*.cpp" -print0)

echo "Collecting C files ..."
cfiles=()
while IFS= read -r -d '' cfile; do
	echo "$cfile"
	cfiles+=("$cfile")
done < <(find "$FULLPATH/$SRC/" -type f -name "*.c" -print0)

echo "Collecting $SRC include paths ..."
includepaths=()
while IFS= read -r -d '' includepath; do
	echo "$includepath"
	includepaths+=("-I$includepath")
done < <(find "$FULLPATH/$SRC/" -type d -print0)

echo "Collecting library include paths ..."
while IFS= read -r -d '' includepath; do
	echo "$includepath"
	includepaths+=("-I$includepath")
done < <(find "$FULLPATH/$LIB/"*/include -maxdepth 0 -type d -print0)

echo "Collecting library search paths ..."
librarysearchpaths=()
while IFS= read -r -d '' librarysearchpath; do
	echo "$librarysearchpath"
	librarysearchpaths+=("-L$librarysearchpath")
done < <(find "$FULLPATH/$LIB/"*/lib/linux -maxdepth 0 -type d -print0)



echo "Creating unity.cpp ..."
UNITYFILE="unity"
UNITYFILENAME="$UNITYFILE.cpp"
UNITYFILEPATH="$FULLPATH/$BUILD/$UNITYFILENAME"
echo "UNITYFILEPATH=$UNITYFILEPATH"
echo "// THIS FILE WAS AUTOMATICALLY GENERATED BY build_unity.sh DO NOT EDIT" > "$UNITYFILEPATH"

for cppfile in "${cppfiles[@]}"; do
	echo "#include \"$cppfile\"" >> "$UNITYFILEPATH"
done

echo "Compiling C++ file ($UNITYFILENAME) ..."
cmd="$CXX $CXXFLAGS ${includepaths[@]/#/} -o \"$FULLPATH/$BUILD/$UNITYFILE.o\" \"$UNITYFILEPATH\""
echo "$cmd"
$($CXX $CXXFLAGS "${includepaths[@]/#/}" -o "$FULLPATH/$BUILD/$UNITYFILE.o" "$UNITYFILEPATH")

ret=$?
if [ "$ret" -ne 0 ]; then
	ELAPSEDTIMESECONDS=$(($SECONDS - $STARTTIMESECONDS))
	echo -e "${RED}Build Failed. (took $ELAPSEDTIMESECONDS second(s))"
	exit $ret
fi

echo "Compiling ${#cfiles[@]} C file(s) ..."
COUNTER=0
for cfile in "${cfiles[@]}"; do
	cfilename="$(basename -- $cfile)"
	objectfilename="${cfilename%.c}.o"
	
	if [ "$ARG1" != "incremental" ] || [ ! -f "$FULLPATH/$BUILD/${COUNTER}_c_$objectfilename" ]; then
		cmd="$CC $CFLAGS -o \"$FULLPATH/$BUILD/${COUNTER}_c_$objectfilename\" \"$cfile\""
		echo "$cmd"
		$($CC $CFLAGS -o "$FULLPATH/$BUILD/${COUNTER}_c_$objectfilename" "$cfile")

		ret=$?
		if [ "$ret" -ne 0 ]; then
			ELAPSEDTIMESECONDS=$(($SECONDS - $STARTTIMESECONDS))
			echo -e "${RED}Build Failed. (took $ELAPSEDTIMESECONDS second(s))"
			exit $ret
		fi
	else
		echo -e "${YELLOW}Skipping compiling $cfile because of incremental build ...${RESET}"
	fi
	
	let COUNTER=COUNTER+1
done

echo "Collecting object files ..."
ofiles=()
while IFS= read -r -d '' ofile; do
	echo "$ofile"
	ofiles+=("$ofile")
done < <(find "$FULLPATH/$BUILD/" -type f -name "*.o" -print0)

echo "Linking ${#ofiles[@]} object file(s) ..."
cmd="$LD $LDFLAGS ${LDFLAGS2[@]/#/} ${librarysearchpaths[@]/#/} -o \"$FULLPATH/$BUILD/$NAME\" ${ofiles[@]/#/} $LDLIBS"
echo "$cmd"
$($LD $LDFLAGS "${LDFLAGS2[@]/#/}" "${librarysearchpaths[@]/#/}" -o "$FULLPATH/$BUILD/$NAME" "${ofiles[@]/#/}" $LDLIBS)

ret=$?
if [ "$ret" -ne 0 ]; then
	ELAPSEDTIMESECONDS=$(($SECONDS - $STARTTIMESECONDS))
	echo -e "${RED}Build Failed. (took $ELAPSEDTIMESECONDS second(s))"
	exit $ret
fi

ELAPSEDTIMESECONDS=$(($SECONDS - $STARTTIMESECONDS))
echo -e "${GREEN}Build Finished. (took $ELAPSEDTIMESECONDS second(s))"
exit 0

