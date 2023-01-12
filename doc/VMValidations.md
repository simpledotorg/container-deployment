# Basic VM validations

* Check ssh connectivity
* Check internet connectivity from VM. `curl google.com`
* Check timezone is configured properly on all the VMs `timedatectl`
* Check NTP is working `timedatectl`
* Check disks and size `lsblk`
* Check memory and CPU size `htop`
* Check OS and Kernel version `uname -r` `cat /etc/issue`
* Ensure hostname is unique on all the hosts `hostname`
* Check outbound SMTP traffic `telnet smtp.sendgrid.net 587`
