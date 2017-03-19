#!/bin/bash

SMACK_MOUNT_POINT=/sys/fs/smackfs
KERNEL_BOOT_PARAM="security=smack ima_policy rootflags=i_version"
FILES_TOBE_MEAS=(/path/to/files)

if [ "$EUID" -ne 0 ]; then 
	echo "Please run as root"
  	exit
fi

apt-get install util-vserver 	#for setfattr

#Add 'smackfs' filesystem to be mounted automatically
if [[ -z `grep smackfs /etc/fstab` ]]; then
	echo "smackfs $SMACK_MOUNT_POINT smackfs defaults 0 0" >> /etc/fstab
fi

#Adding kernel boot parameters and i_version support (for re-measurement)
#NOTE: if their are multiple filesystems the i_version needs to
#be enabled manually in /etc/fstab
if [[ -z `grep $KERNEL_BOOT_PARAM /etc/default/grub` ]]; then
	REPLACE=`grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub`
	NEWCMD="${REPLACE::-1} $KERNEL_BOOT_PARAM\""

	sed -i "/$REPLACE/c\\$NEWCMD" /etc/default/grub

	update-grub
fi

echo "_ M rwxa" > $SMACK_MOUNT_POINT/load2

for file in "${FILES_TOBE_MEAS[@]}"; do
	setfattr -n security.SMACK64 -v M $file
done
