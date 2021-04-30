#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# root of the os style configs being downloaded
setupRoot="$1"
temp="$2"
tempShared="$3"
tempThis="$4"

mkdir -p "$HOME/.vim/bundle"
mkdir -p "$HOME/.vim/swap"
mkdir -p "$HOME/vimfiles/plugin-settings"
mkdir -p "$HOME/clipboard"
mkdir -p "$HOME/bin"
mkdir -p "/c/Tasks"
mkdir -p "/c/vscodevim"
mkdir -p "$HOME/AppData/Roaming/Code/User/"

unset setupRoot
unset tempShared
unset tempThis
unset temp

