#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

mkdir -p ~/.vim/bundle
mkdir -p ~/.vim/swap
mkdir -p ~/vimfiles/plugin-settings
mkdir -p ~/bin
mkdir -p ~/clipboard
mkdir -p ~/bin
mkdir -p ~/Tasks
mkdir -p ~/vscodevim

cd ~
cp -a "$SCRIPTPATH/../../../shared/required/home/." .
cp -a "$SCRIPTPATH/../home/." .
ls -A | xargs dos2unix

cd ~/bin
cp -a "$SCRIPTPATH/../../../shared/required/home_bin/." .
ls -A | xargs dos2unix

cd ~/clipboard
cp -a "$SCRIPTPATH/../../../shared/required/clipboard/." ~/clipboard/
ls -A | xargs dos2unix

cd ~/Tasks
cp -a "$SCRIPTPATH/../../../shared/required/Tasks/." ~/Tasks/
ls -A | xargs dos2unix

cd ~/vscodevim
cp -a "$SCRIPTPATH/../../../shared/required/vscodevim/." ~/vscodevim/
ls -A | xargs dos2unix

# temp _vimrcterm
cp "$SCRIPTPATH/../../../shared/required/home/_vimrcterm" "$SCRIPTPATH/_vimrcterm"
# replace .exe with nothing
sed -i.bak 's/bash\.exe/bash/g' "$SCRIPTPATH/_vimrcterm"
# override _vimrcterm
cp -a "$SCRIPTPATH/_vimrcterm" ~/_vimrcterm
rm "$SCRIPTPATH/_vimrcterm"
rm "$SCRIPTPATH/_vimrcterm.bak"

# temp _vsvimrc 
cp "$SCRIPTPATH/../../../shared/required/vscodevim/_vsvimrc" "$SCRIPTPATH/_vsvimrc"
# replace .exe with nothing
sed -i.bak 's/bash\.exe/bash/g' "$SCRIPTPATH/_vsvimrc"
# override _vsvimrc 
cp -a  "$SCRIPTPATH/_vsvimrc" ~/_vsvimrc
rm "$SCRIPTPATH/_vsvimrc"
rm "$SCRIPTPATH/_vsvimrc.bak"

# download vundle if it does not exist
vunDir="$HOME/.vim/bundle/Vundle.vim"
[[ -d $vunDir ]] || {
  cd ~/.vim/bundle
  git clone https://github.com/VundleVim/Vundle.vim.git "$vunDir"
  find . -exec readlink -f {} \; | xargs dos2unix
  cd ~
}
