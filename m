From: Wendy Cheng <s.wendy.cheng@gmail.com>
Date: Fri, 11 Oct 2013 20:28:45 -0700
Subject: [Lustre-devel] [Patch] Fix Client Kernel Crash with Mis-configured
	Index Numbering
Message-ID: <CABgxfbH-js0JZzSAienCMJgXQYzVsKUYHbpfJWbvPfakyFGT6w@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ref: http://lists.lustre.org/pipermail/lustre-devel/2013-October/004270.html

I'm not really convinced the "index" setting of mkfs.lustre needs to
be started with "0". However, in the minimum, the client kernel should
not crash. The attached patch does this minimum fix; compiled and
tested with GIT master branch.

Recreated by:
server> mkfs.lustre --reformat --fsname=lus1 --mgs --mdt --index=1 /dev/sdd1
server> mkfs.lustre --reformat --ost --fsname=lus1
--mgsnode=192.168.20.46 at o2ib0 --index=1 /dev/sde1

client> mount.lustre -o flock 192.168.20.46 at o2ib0:/lus1 /mnt/lustre

The client mount crashes at lmv_get_info() without changes

<1>[  215.946538] BUG: unable to handle kernel NULL pointer
dereference at 0000000000000028
<1>[  215.946572] IP: [<ffffffffa07445cb>] lmv_get_info+0x32b/0x560 [lmv]
<0>[  215.947090] Call Trace:^M
<4>[  215.947143]  [<ffffffffa0655b70>] ll_fill_super+0x1f40/0x4330 [lustre]^M
<4>[  215.947214]  [<ffffffffa02cf527>] ?
lustre_start_mgc+0x227/0x2a90 [obdclass]^M
<4>[  215.947275]  [<ffffffffa02d3d60>] lustre_fill_super+0xa20/0x22f0
[obdclass]^M
<4>[  215.947304]  [<ffffffff810de91f>] ? set_anon_super+0x0/0xe0^M
<4>[  215.947361]  [<ffffffffa02d3340>] ? lustre_fill_super+0x0/0x22f0
[obdclass]^M
<4>[  215.947380]  [<ffffffff810df601>] mount_nodev+0x50/0x84^M
<4>[  215.947437]  [<ffffffffa02cc5d9>] lustre_mount+0x29/0x30 [obdclass]^M
<4>[  215.947454]  [<ffffffff810df009>] vfs_kern_mount+0xa8/0x1f3^M
<4>[  215.947471]  [<ffffffff810df1bc>] do_kern_mount+0x4d/0xe1^M
<4>[  215.947489]  [<ffffffff810f54d7>] do_mount+0x67d/0x6d5^M
<4>[  215.947507]  [<ffffffff810f57cc>] sys_mount+0x84/0xbd^M
<4>[  215.947527]  [<ffffffff81002aab>] system_call_fastpath+0x16/0x1b^M

Signed-off-by: Wendy Cheng <wendy.cheng@intel.com>

diff --git a/lustre/lmv/lmv_obd.c b/lustre/lmv/lmv_obd.c
index 3091bfb..5f4a18b 100644
--- a/lustre/lmv/lmv_obd.c
+++ b/lustre/lmv/lmv_obd.c
@@ -2443,6 +2443,16 @@ static int lmv_get_info(const struct lu_env
*env, struct obd_export *exp,
                         RETURN(rc);

                /*
+                * In the case of mis-configured OSS, instead of crashing
+                * the kernel during client mount, give them a warning and
+                * gracefully back out mount process w/ -ENXIO error.
+                */
+               if (lmv->tgts[0] == NULL) {
+                       CDEBUG(D_IOCTL, "NULL index\n");
+                       RETURN(-ENXIO);
+               }
+
+               /*
                 * Forwarding this request to first MDS, it should know LOV
                 * desc.
                 */
