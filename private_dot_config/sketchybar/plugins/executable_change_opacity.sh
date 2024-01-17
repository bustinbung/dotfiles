#!/bin/bash

while getopts 'a:s:' flag; do
    case "${flag}" in
        a) MODE="add"; VALUE="$OPTARG" ;;
        s) MODE="subtract"; VALUE="$OPTARG" ;;
        *) echo "-a [ADD VALUE] | -s [SUBTRACT VALUE]" ;;
    esac
done

case "$MODE" in
    "add") echo `printf "0x%X\n" $(( $3 + $VALUE ))`;;
    "subtract") echo `printf "0x%X\n" $(( $3 - $VALUE ))`;;
esac
