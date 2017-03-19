# Measuring single files in Linux IMA

To be able to measure specific single files in Linux IMA, _SMACK_ can be used. To see if SMACK is available and enabled on a system run the command 

```grep CONFIG_SECURITY_SMACK /boot/config-`uname -r` ```

This should return something similar to 

```
CONFIG_SECURITY_SMACK=y
#CONFIG_SECURITY_SMACK_BRINGUP is not set
CONFIG_SECURITY_SMACK_NETFILTER=y
```
 
 
 The next step is to mount the _smackfs_ filesystem, which is needed to define the later used policies. First, the line
 
 ```smackfs /sys/fs/smackfs smackfs defaults 0 0```
 
 must be added to _/etc/fstab_. This will tell the system to mount the _smackfs_ filesystem automatically on startup. Second, the following parameters have to be added to the kernel boot parameters
 
 ```security=smack ima_policy rootflags=i_version```
 
 
 The first paramter tells the system to use the _SMACK_ security module. _ima\_policy_ tells the system to use the specified IMA policy and _rootflags=i\_version_ is set to mount the root directory with i\_version support, which allows IMA the re-measuring of files to detect changes.
 
 To be able to measure files, a SMACK label must be defined by setting a policy with the command
 
 ```echo "_ M rwxa" > /sys/fs/smackfs/load2```
 
 Now, files that have to be measured can be marked by setting the "M" attribute, with the following command
 
 ```setfattr -n security.SMACK64 -v M <file>```
 
 The measurement of the specified files is triggered every time they are accessed.
The measurements of the files can be found in the file _/sys/kernel/security/ima/ascii\_runtime\_measurements_.


An automated version of the above steps can be found in the script ```mark_files.sh```
