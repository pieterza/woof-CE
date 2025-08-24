#!/bin/bash
# convert a puppy iso into netboot-compatible vmlinuz and humongous initrd.gz
# Edited by Master_wrong so can save to other media not just temp

echo "This script will create a set of files suitable for puppy netbooting.
The input is a puppy ISO file. The output will be located in /tmp/netboot - one vmlinuz and one huge initrd.gz.
If /root/tftpboot/pxelinux.cfg exist, the output files will be symlinked to this directory as well,
so you can use netboot-server to server them straight away." 0 0

#ISO="/tmp/ccs64ce-99999.1.iso"
ISO=$1
if [ "$ISO" == "" ]; then
  echo "usage: $0 /path/to/iso"
  exit 1
fi
tmp="mnt/sdc2"
tmp2="mnt/sdc2"
if [ -n "$ISO" ]; then
rm -rf /$tmp2/netboot /$tmp/netboot_iso
mkdir -p /$tmp2/netboot/x /$tmp/netboot_iso
if mount -o loop "$ISO" /$tmp/netboot_iso; then
if [ -f /$tmp/netboot_iso/vmlinuz -a -f /$tmp/netboot_iso/initrd.gz ]; then
echo "This will take a while. Please wait ..." 0 0 60000 &
PID=$!
cp /$tmp/netboot_iso/vmlinuz /$tmp2/netboot
cd /$tmp2/netboot/x
zcat /$tmp/netboot_iso/initrd.gz | cpio -i
cp /$tmp/netboot_iso/*.sfs .
sed -i 's#mv -f $ONE_FN /mnt/tmpfs#echo 123#g' init
find . | cpio -o -H newc | gzip -9 > ../initrd.gz
fi
fi
fi
