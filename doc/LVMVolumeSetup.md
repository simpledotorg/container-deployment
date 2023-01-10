# Create LVM volume on with configured with LVM

Check existing volumes and groups
* `sudo lvs`

Create new volume
* `sudo lvcreate -n data -L 800G ubuntu-vg`

Format the volume
* `sudo mkfs -t ext4 /dev/ubuntu-vg/data`

Create fstab entry to auto mount on reboot
* Use `sudo blkid` to get the volume uuid 
* `sudo vim /etc/fstab`
* Add `UUID=<uuid> /path/to/mount ext4 defaults 0 0` to `/etc/fstab` file
