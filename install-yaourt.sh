#!/bin/bash

sudo pacman -S --needed base-devel

set -ex

TEMP=$(mktemp -d)
cd "$TEMP"

curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yaourt
makepkg PKGBUILD
sudo pacman -U package-query*.tar.xz --noconfirm


curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yaourt
makepkg PKGBUILD
sudo pacman -U yaourt*.tar.xz --noconfirm

rm -r "$TEMP"
