Boot On Live Distribution
=========================

    loadkeys be-latin1

Partition
---------

    fdisk -l

For all disks:

    fdisk /dev/sdX
    g<Enter>
    n<Enter>...
    t<Enter>
    16<Enter>
    w<Enter>


Create lvm volumes
------------------

Follow instuctions in lvm

root 20G
home 100G
var 10G
swap 2G
mkswap /dev/strip/swap
swapon /dev/strip/swap


Mount partitions
----------------

First root, then create directories

mount /mnt /dev/strip/root
mkdir /mnt/home; mount /dev/strip/home /mnt/home
mkdir /mnt/var; mount /dev/strip/var /mnt/var

Connect internet
----------------

Nothing to do with wired DHCP


Update hardware clock
---------------------








Install the filesystem
----------------------

g
n

+1M
t
4

vgcreate strip /dev/sda2

XXXXXXXXXXXXXXXXXXX

Connect to internet
-------------------

Simply issue dhcpcd


Update hardware clock
---------------------

Interpret hardware clock as UTC:
    timedatectl set-local-rtc 0


Install
-------

pacstrap /mnt base
# Next step only if required key missing from keyring error
pacman -Sy archlinux-keyring
# Then pacstrap again
genfstab -p /mnt >> /mnt/etc/fstab
arch-chroot /mnt
echo hal > /etc/hostname
ln -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime
vi /etc/locale.gen   # uncomment locale en_US.UTF-8
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
echo KEYMAP=be-latin1 > /etc/vconsole.conf
vi /etc/mkinitcpio.conf   # add lvm2 between block and filesystems
mkinitcpio -p linux
passwd

# if needed
pacman-db-upgrade
pacman -Syu vim

pacman -Sy grub
grub-install --target=i386-pc --recheck --debug /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
vim /boot/grub/grub.cfg   # change root= to point to the correct root - should be OK but better safe than sorry
# :r! ls -l /dev/disk/by-uuid
# :r! ls -l /dev/mapper

exit
umount -R

Remove USB key


Post-Install
============

Users
-----
vim /etc/profile   # change umask to 002
useradd -m -G wheel -s /bin/zsh USER 
passwd USER

Network
-------
ln -fs /run/systemd/resolve/resolv.conf /etc/resolv.conf
cat <<EOF > /etc/systemd/network/wired.network
[Match]
Name=enp1s0

[Network]
DNS=10.1.10.1

[Address]
Address=10.1.10.9/24

[Route]
Gateway=10.1.10.1
EOF
systemctl start systemd-networkd
systemctl enable systemd-networkd
systemctl start systemd-resolved
systemctl enable systemd-resolved

Packages
--------

pacman -Syu vim git zsh sudo tmux
https://wiki.archlinux.org/index.php/Man_page#Using_less_.28Recommended.29

Privileges
----------

visudo   # uncomment for wheel

SSH
---

pacman -Syu openssh
vim /etc/ssh/sshd_config   # PermitRootLogin no
# configure following http://stribika.github.io/2015/01/04/secure-secure-shell.html
systemctl start sshd
systemctl enable sshd

cd $HOME
mkdir .ssh
chmod 700 .ssh

Time
----

pacman -Syu ntp
systemctl start ntpd
systemctl enable ntpd

Monitoring & Performance
------------------------

pacman -Syu hdparm
hdparm -I /dev/sdX
hdparm -t --direct /dev/sdX
hdparm -B /dev/sdX
vim /etc/makepkg.conf   # uncomment BUILDDIR=/tmp/makepkg
yaourt -Syua anything-sync-daemon
free -h
pstree
# Optimize file access in large directories
tune2fs -O dir_index /dev/strip/root
e2fsck -D -f /dev/strip/root  # apply to existing directories

https://wiki.archlinux.org/index.php/Anything-sync-daemon ?

Completion
----------

usermod -s /bin/zsh root
vim /etc/inputrc    # add set show-all-if-ambiguous on
pacman -Syu zsh-completions zsh-syntax-highlighting

cat <<EOF > /home/timi/.zshrc
autoload -U compinit
compinit

autoload -U promptinit
promptinit

autoload -U colors
colors

export VISUAL="vim"

##############
# Completion #
##############
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true  # auto rehash
setopt completealiases

###########
# History #
###########
setopt HIST_IGNORE_DUPS
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"    history-beginning-search-backward
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}"  history-beginning-search-forward


################################
# Remember visited directories #
################################
# dirs -v
# cd -<NUM>

DIRSTACKFILE="$HOME/.cache/zsh/dirs"
[[ -f $DIRSTACKFILE ]] || mkdir -p "$HOME/.cache/zsh"
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
    dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
    [[ -d $dirstack[1] ]] && cd $dirstack[1]
fi

chpwd() {
    print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}

DIRSTACKSIZE=20

setopt autopushd pushdsilent pushdtohome

## Remove duplicate entries
setopt pushdignoredups

## This reverts the +/- operators.
setopt pushdminus

#######################
# Syntax Highlighting #
#######################
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

EOF

tmux
----

set -g default-terminal "screen-256color" 
set -g history-limit 10000
set -g default-command "${SHELL}"

Maintenance
-----------

journalctl -p 0..3 -xn

Yaourt
------

git clone https://github.com/ibizaman/docsnippet.git
cd docsnippet
./install-yaourt.sh

Atlassian
=========

pacman -S jdk8-openjdk postgresql
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
systemctl start mysqld
systemctl enable mysqld
'/usr/bin/mysqladmin' -u root password
'/usr/bin/mysqladmin' -u root -p -h localhost password
