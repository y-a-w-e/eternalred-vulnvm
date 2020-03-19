#!/bin/bash
############################# SAMBA VULN
# Title : ETERNALRED 
# Date: 05/24/2017
# Exploit Author: steelo <knownsteelo@gmail.com>
# Vendor Homepage: https://www.samba.org
# Samba 3.5.0 - 4.5.4/4.5.10/4.4.14
# CVE-2017-7494

set -e
set -o pipefail
export DEBIAN_FRONTEND="noninteractive"

apt-get update -y
apt-get upgrade -y
apt-get install git perl gcc g++ python-dev -y

cd /opt/
git clone https://github.com/samba-team/samba.git

cd /opt/samba
# checkout vulnerable version 4.0
git checkout v4-0-test

# manual fix line 59 in ./buildtools/wafsamba/samba_perl.py
# add: if '.' in perl_inc:
sed -i "s/perl_inc.remove('.')/if '.' in perl_inc:\n        perl_inc.remove('.')/g" /opt/samba/buildtools/wafsamba/samba_perl.py

./configure

# remove "define" from some source files that throws error
sed -i "s/(defined(\@\$podl))/(\@\$podl)/g" /opt/samba/pidl/lib/Parse/Pidl/ODL.pm
sed -i "s/defined \@\$pidl/\@\$pidl/g" /opt/samba/pidl/pidl

# compile This will take some Time
echo "This will take some Time"
make
make install

# add PATH environment var
export PATH=/usr/local/samba/bin/:/usr/local/samba/sbin/:$PATH

# https://wiki.samba.org/index.php/Setting_up_Samba_as_a_Standalone_Server
# The [Share] sction is our vulnerability

echo "
[global]
        map to guest = Bad User
        log file = /var/log/samba/%m
        log level = 1

[guest]
        # This share allows anonymous (guest) access
        # without authentication!
        path = /srv/samba/guest/
        read only = no
        guest ok = yes

[demo]
        # This share requires authentication to access
        path = /srv/samba/demo/
        read only = no
        guest ok = no

[Share]
        comment = 'Exploitable Share Folder'
        path = /tmp
        public = yes
        writeable = yes

" >> /usr/local/samba/etc/smb.conf

# Add some samba configurations
# this is not needed for the vulnerability
# Add a samba user 
adduser --gecos "" 'smbuser' <<END
samba123
samba123
END

## change password samba
smbpasswd -a smbuser -s <<EOF
samba123
samba123
EOF

smbpasswd -e smbuser

# Add a samba group
groupadd smbgroup
usermod -aG smbgroup smbuser

# make some directorys
mkdir -p /srv/samba/guest/
mkdir -p /srv/samba/demo/

chgrp -R smbgroup /srv/samba/guest/
chgrp -R smbgroup /srv/samba/demo/
chmod 2775 /srv/samba/guest/
chmod 2770 /srv/samba/demo/

# add a start samba service
echo "
[Unit]
Description=Vulnerable Samba Deamon
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/samba/
Environment=PATH=/usr/local/samba/bin/:/usr/local/samba/sbin/:$PATH
ExecStart=/usr/local/samba/sbin/smbd -DF

[Install]
WantedBy=multi-user.target

" >> /etc/systemd/system/smbd-start.service

systemctl enable smbd-start.service
systemctl start smbd-start.service

t00H4rdT0C4ck1337