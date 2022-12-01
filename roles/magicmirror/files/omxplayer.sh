#!/bin/bash

## Just for fun
#for arg in "$@"
#do
#    echo "Argument - $i: $arg";
#    i=$((i + 1));
#done
#
## Get the options
#while getopts "o:" option
#do
#   case "$option" in
#      o) theOoption=${OPTARG};;
#   esac
#done
#
#echo "the O option is :$theOoption"
shift 2
#echo $@
MP3_REGEX="(mp3|MP3)"

if [[ $@ =~ $MP3_REGEX ]];
then
    #MP3
    mpg321 $@
else
    #WAV
    aplay $@
fi


