#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# root of the os style configs being downloaded
setupRoot="$1"
temp="$2"
tempShared="$3"
tempThis="$4"

vsvimpath="$(echo "$HOME/vscodevim/_vsvimrc" | sed 's,^/c,c:,g' | sed -E 's,/,\\\\\\\\,g')"
find "$tempShared" -regextype egrep -iregex ".*\.json" -type f -exec sed -E -i'' "s,VSVIM_DIR_PLACEHOLDER,$vsvimpath,g" {} \;
find "$tempShared" -regextype egrep -iregex ".*vim.*" -type f -exec sed -i'' 's/VIM_PLUGIN_IMPORT_PLACEHOLDER/so ~\/_vim_plugins/g' {} \;
find "$tempShared" -regextype egrep -iregex ".*vim.*" -type f -exec sed -i'' 's,VIM_SHELL_PLACEHOLDER,/bin/bash.exe,g' {} \;
find "$tempShared" -regextype egrep -iregex ".*" -type f -exec sed -E -i'' "s,OS_PLACEHOLDER,windows,g" {} \;

unset setupRoot
unset tempShared
unset tempThis
unset temp

