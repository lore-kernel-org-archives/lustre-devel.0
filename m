From: Ankit Ladhania <ankit@tripock.com>
Date: Fri, 15 May 2020 17:53:53 +0530
Subject: [lustre-devel] Lustre ZFS OSD for Ubuntu/Debian
Message-ID: <CAKVGuZZLiC9kLt_LbQ880iZKsdTYD=svQHo4b7K58CkuP9p9Zw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,
I'm a newbie in Lustre and am trying to install it on top of ZFS. I'm using
Ubuntu 16.04.

I have installed the latest ZFS (built from source)
zfs-0.8.4-1
zfs-kmod-0.6.5.6-0ubuntu26

I have installed the latest Lustre (built from source):
lustre-dev_2.12.4-60-g8ecf56c-1_amd64.deb
lustre-iokit_2.12.4-60-g8ecf56c-1_amd64.deb
lustre-resource-agents_2.12.4-60-g8ecf56c-1_amd64.deb
lustre-server-modules-4.4.0-142-generic_2.12.4-60-g8ecf56c-1_amd64.deb
lustre-server-utils_2.12.4-60-g8ecf56c-1_amd64.deb
lustre-source_2.12.4-60-g8ecf56c-1_all.deb
lustre-tests_2.12.4-60-g8ecf56c-1_amd64.deb

As per the doc I have created zpool:
$ sudo zpool create  -fd -O canmount=off  mgspool mirror /dev/sdb /dev/sdc

then:
$ sudo mkfs.lustre --reformat --fsname=zeblok --mgs
--servicenode=130.245.177.196 at tcp --backfstype=zfs --verbose mgspool/mgt

when I'm trying to mount the file system:
$ sudo mount -t lustre mgspool/mgt /mnt/mdt
mount.lustre: mgspool/mgt is configured for failover but zpool does not
have multihost enabled
mount.lustre: mgspool/mgt is configured for failover but zpool does not
have multihost enabled
mount.lustre: mount mgspool/mgt at /mnt/mdt failed: No such device
Are the lustre modules loaded?
Check /etc/modprobe.conf and /proc/filesystems

In dmesg I'm getting the below error:
LustreError: 158-c: Can't load module 'osd-zfs'
[836981.548061] LustreError: 30106:0:(genops.c:397:class_newdev()) OBD:
unknown type: osd-zfs
[836981.669172] LustreError: 30106:0:(obd_config.c:403:class_attach())
Cannot create device MGS-osd of type osd-zfs : -19
[836981.790888] LustreError:
30106:0:(obd_mount.c:197:lustre_start_simple()) MGS-osd attach error -19
[836981.913181] LustreError:
30106:0:(obd_mount_server.c:1956:server_fill_super()) Unable to start osd
on mgspool/mgt: -19
[836982.035378] LustreError: 30106:0:(obd_mount.c:1608:lustre_fill_super())
Unable to mount  (-19)

I see that in centos there is a rpm that is asked to install:

*lustre-osd-zfs-mount*

What is the alternative in debian?

Thanks for all the help.


*Regards,*
*Ankit Ladhania*
IN: +91 933 444 2209
US:  +1 (256) 203-0077
Skype: ankit.ladhania
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200515/9602ab61/attachment.html>
