#!/bin/bash

set -ouex pipefail

### Install packages

# Install from Fedora repos
dnf5 install -y borgbackup borgmatic btrfsmaintenance fish glances micro plocate screen smartmontools snapper nut-client sshguard ncdu prometheus-podman-exporter

# Build & install bees
dnf -y install make gcc gcc-c++ btrfs-progs markdown
git clone https://github.com/Zygo/bees.git
cd bees
git checkout v0.11
make install
cd ..
rm -rf bees

#### Systemd & configuration

# system watchdog
install -Dm 644 /ctx/system_files/etc/systemd/system.conf.d/watchdog.conf /etc/systemd/system.conf.d/watchdog.conf

# plocate
install -Dm 644 /ctx/system_files/etc/updatedb.conf /etc/updatedb.conf
systemctl enable plocate-updatedb.timer

# snapper
systemctl enable snapper-cleanup.timer
systemctl enable snapper-timeline.timer

# btrfsmaintenance
install -Dm 644 /ctx/system_files/etc/sysconfig/btrfsmaintenance /etc/sysconfig/btrfsmaintenance
systemctl enable btrfsmaintenance-refresh.path
systemctl enable btrfs-scrub.timer
systemctl enable btrfs-balance.timer

# tailscale
systemctl enable tailscaled.service

# cockpit
systemctl enable cockpit.service

# sshguard
systemctl enable sshguard.service
install -Dm 644 /ctx/system_files/etc/sshguard.conf /etc/sshguard.conf
install -Dm 644 /ctx/system_files/etc/sshguard.whitelist /etc/sshguard.whitelist

# borgmatic
systemctl enable borgmatic.timer
