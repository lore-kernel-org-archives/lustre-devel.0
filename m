From: SoVo Le <lesovo@gmail.com>
Date: Tue, 29 Jul 2008 11:25:54 -0700
Subject: [Lustre-devel] Centos 5.2 with Lustre 1.6.5.1
Message-ID: <52ce537f0807291125r5d27fcf1m5710838a8e27e93c@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

If someone could help me out on this:  Why can't I mount lustre ?


[root at lustre_server ~]# mkfs.lustre --reformat --device-size=300000 --mdt
--mgs --param lov.stripcount=3 --param lov.stripesize=4M /dev/sdb

   Permanent disk data:
Target:     lustre-MDTffff
Index:      unassigned
Lustre FS:  lustre
Mount type: ldiskfs
Flags:      0x75
              (MDT MGS needs_index first_time update )
Persistent mount opts: errors=remount-ro,iopen_nopriv,user_xattr
Parameters: lov.stripcount=3 lov.stripesize=4M
mdt.group_upcall=/usr/sbin/l_getgroups

2 6 18
formatting backing filesystem ldiskfs on /dev/sdb
        target name  lustre-MDTffff
        4k blocks     75000
        options        -i 4096 -I 512 -q -O dir_index,uninit_groups -F
mkfs_cmd = mkfs.ext2 -j -b 4096 -L lustre-MDTffff  -i 4096 -I 512 -q -O
dir_index,uninit_groups -F /dev/sdb 75000
Writing CONFIGS/mountdata

[root at lustre_server ~]# mount -t lustre /dev/sdb /mnt/mdt
[root at lustre_server ~]# mkdir /mnt/mdt
[root at lustre_server ~]# mount -t lustre /dev/sdb /mnt/mdt
mount.lustre: mount /dev/sdb at /mnt/mdt failed: *Operation not supported
*


/var/log/messages shows:

Jul 29 11:14:47 lustre_server kernel: Lustre: Skipped 1 previous similar
message
Jul 29 11:14:47 lustre_server kernel: Lustre: *** setting obd lustre-MDT0000
device 'unknown-block(8,16)' read-only ***
Jul 29 11:14:47 lustre_server kernel: Turning device sdb (0x800010)
read-only
Jul 29 11:14:47 lustre_server kernel: Lustre: lustre-MDT0000: shutting down
for failover; client state will be preserved.
Jul 29 11:14:47 lustre_server kernel: Lustre: MDT lustre-MDT0000 has
stopped.
Jul 29 11:14:47 lustre_server kernel: LustreError:
14992:0:(ldlm_request.c:986:ldlm_cli_cancel_req()) Got rc -108 from cancel
RPC: canceling anyway
Jul 29 11:14:47 lustre_server kernel: LustreError:
14992:0:(ldlm_request.c:1575:ldlm_cli_cancel_list()) ldlm_cli_cancel_list:
-108
Jul 29 11:14:47 lustre_server kernel: Lustre: MGS has stopped.
Jul 29 11:14:47 lustre_server kernel: Removing read-only on sdb (0x800010)
Jul 29 11:14:47 lustre_server kernel: Lustre: server umount lustre-MDT0000
complete

TIA

PS:  I have no problem mounting lustre on RedHat 5.2 with Lustre 1.6.5.1
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080729/f61160c5/attachment.htm>
