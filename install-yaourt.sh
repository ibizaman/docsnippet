#!/bin/bash

pacman -S --needed base-devel

cd_to="$1"
[ -z "$cd_to" ] && cd_to=.

set -e

cd $cd_to

curl -O https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz
tar zxvf package-query.tar.gz
cd package-query
makepkg -si
cd ..

curl -O https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz
tar zxvf yaourt.tar.gz
cd yaourt
makepkg -si
cd ..
