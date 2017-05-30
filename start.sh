#!/bin/bash

set -x
set -e

{

if [ "$(id -u)" != "0" ]; then
   echo "Please give me root permission" 1>&2
   exit 1
fi

service rsyslog stop

export DEBIAN_FRONTEND=noninteractive
apt-get autoremove --purge -y
apt-get clean
apt-get autoclean

rm -f /etc/ssh/ssh_host_*
rm -f /root/.bash_history
rm -f /home/*/.bash_history
rm -f /var/cache/apt/*.bin
rm -f /var/cache/apt/archives/*.deb
rm -f /var/cache/apt/archives/partial/*.deb
rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -f /var/lib/dhcp*/*leases*
rm -rf /root/.ssh/*
rm -rf /home/*/.ssh/*
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
rm -rf /var/tmp/*


logrotate --force /etc/logrotate.conf
find /var/log -type f -name "*.log" -exec cp /dev/null {} \;
find /var/log -type f \( -name "*.gz" -o -name "*.0" -o -name "*.1" \) -exec rm -f {} \;

for logfile in audit/audit.log wtmp lastlog
do
    [ -f "/var/log/${logfile}" ] && cat /dev/null > "/var/log/${logfile}"
done

cp /etc/rc.local /etc/rc.local.orig
sed -i '$ i dpkg-reconfigure openssh-server\nmv /etc/rc.local.orig /etc/rc.local' /etc/rc.local

cat /dev/null > /etc/hostname

history -c
history -w
}
