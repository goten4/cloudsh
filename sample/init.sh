#!/bin/bash
source $(dirname $0)/init.env
echo "Initialize locale..."
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

echo "Add saltstack debian repository..."
wget --no-check-certificate -O - https://repo.saltstack.com/apt/debian/9/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add -
echo "deb http://repo.saltstack.com/apt/debian/9/amd64/latest stretch main" > /etc/apt/sources.list.d/saltstack.list
apt-get update
apt-get -y --allow-unauthenticated -o DPkg::Options::=--force-confold dist-upgrade
apt-get install -y --allow-unauthenticated -o DPkg::Options::=--force-confold salt-minion python-tornado python-pycurl python-m2crypto

echo "Enable salt-minion service on boot..."
systemctl enable salt-minion.service
echo "Set salt configuration..."
echo "master: ${master}" > /etc/salt/minion.d/minion.conf
if [ ${script_env[*]} > 0 ]; then
    echo "roles:" > /etc/salt/grains
    for role in ${roles[*]}; do
        echo "  - ${role}" >> /etc/salt/grains
    done
fi

if [ "${salt_master}" == true ]; then
    apt-get install -y --allow-unauthenticated -o DPkg::Options::=--force-confold salt-master
    echo "Enable salt-master service on boot..."
    systemctl enable salt-master.service
fi

echo "Initialization done, it's time to reboot..."
reboot