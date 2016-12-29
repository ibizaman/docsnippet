#!/bin/bash

sudo pacman -S --noconfirm --needed base-devel expac yajl git

set -ex

TEMP=$(mktemp -d)
cd "$TEMP"

gpg --recv-keys 1EB2638FF56C0C53

curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower
makepkg PKGBUILD
sudo pacman -U cower*.tar.xz --noconfirm

curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
makepkg PKGBUILD
sudo pacman -U pacaur*.tar.xz --noconfirm

rm -r "$TEMP"
